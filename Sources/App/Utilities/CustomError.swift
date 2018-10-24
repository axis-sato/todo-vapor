//
//  CustomError.swift
//  App
//
//  Created by Masahiko Sato on 2018/10/23.
//
import Vapor

enum CustomError: AbortError {
    case notFoundTodo, todoIdValidationError
    
    var identifier: String {
        switch self {
        case .notFoundTodo:
            return "notFoundTodo"
        case .todoIdValidationError:
            return "todoIdValidationError"
        }
    }

    var status: HTTPResponseStatus {
        switch self {
        case .notFoundTodo:
            return .notFound
        case .todoIdValidationError:
            return .badRequest
        }
    }

    var reason: String {
        switch self {
        case .notFoundTodo:
            return "Todoが見つかりませんでした。"
        case .todoIdValidationError:
            return "idの形式が不正です"
        }
    }
    
}
