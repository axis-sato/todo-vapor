//
//  CustomErrorMiddleware.swift
//  App
//
//  Created by Masahiko Sato on 2018/10/27.
//
import Vapor

public final class CustomErrorMiddleware: Middleware, ServiceType {
    /// Structure of `ErrorMiddleware` default response.
    internal struct ErrorResponse: Codable {
        /// Always `true` to indicate this is a non-typical JSON response.
        var code: Int
        
        /// The reason for the error.
        var message: String
    }
    
    /// See `ServiceType`.
    public static func makeService(for worker: Container) throws -> CustomErrorMiddleware {
        return try .default(environment: worker.environment, log: worker.make())
    }
    
    /// Create a default `CustomErrorMiddleware`. Logs errors to a `Logger` based on `Environment`
    /// and converts `Error` to `Response` based on conformance to `AbortError` and `Debuggable`.
    ///
    /// - parameters:
    ///     - environment: The environment to respect when presenting errors.
    ///     - log: Log destination.
    public static func `default`(environment: Environment, log: Logger) -> CustomErrorMiddleware {
        return .init { req, error in
            // log the error
            log.report(error: error, verbose: !environment.isRelease)
            
            // variables to determine
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders
            let code: Int
            
            // inspect the error type
            switch error {
            case let customError as CustomError:
                // this is an abort error, we should use its status, reason, and headers
                reason = customError.reason
                status = customError.status
                headers = customError.headers
                code = customError.code
            case let abort as AbortError:
                // this is an abort error, we should use its status, reason, and headers
                reason = abort.reason
                status = abort.status
                headers = abort.headers
                code = -1
            case let validation as ValidationError:
                // this is a validation error
                reason = validation.reason
                status = .badRequest
                headers = [:]
                code = -1
            case let debuggable as Debuggable where !environment.isRelease:
                // if not release mode, and error is debuggable, provide debug
                // info directly to the developer
                reason = debuggable.reason
                status = .internalServerError
                headers = [:]
                code = -1
            default:
                // not an abort error, and not debuggable or in dev mode
                // just deliver a generic 500 to avoid exposing any sensitive error info
                reason = "Something went wrong."
                status = .internalServerError
                headers = [:]
                code = -1
            }
            
            // create a Response with appropriate status
            let res = req.response(http: .init(status: status, headers: headers))
            
            // attempt to serialize the error to json
            do {
                let errorResponse = ErrorResponse(code: code, message: reason)
                res.http.body = try HTTPBody(data: JSONEncoder().encode(errorResponse))
                res.http.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                res.http.body = HTTPBody(string: "Oops: \(error)")
                res.http.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return res
        }
    }
    
    /// Error-handling closure.
    private let closure: (Request, Error) -> (Response)
    
    /// Create a new `ErrorMiddleware`.
    ///
    /// - parameters:
    ///     - closure: Error-handling closure. Converts `Error` to `Response`.
    public init(_ closure: @escaping (Request, Error) -> (Response)) {
        self.closure = closure
    }
    
    /// See `Middleware`.
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        let response: Future<Response>
        do {
            response = try next.respond(to: req)
        } catch {
            response = req.eventLoop.newFailedFuture(error: error)
        }
        
        return response.mapIfError { error in
            return self.closure(req, error)
        }
    }
}
