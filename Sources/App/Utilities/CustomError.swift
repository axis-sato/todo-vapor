//
//  CustomError.swift
//  App
//
//  Created by Masahiko Sato on 2018/10/23.
//
import Vapor

enum CustomError: AbortError {
    case notFoundTodo, todoIdValidationError, todoValidationError
    
    var identifier: String {
        switch self {
        case .notFoundTodo:
            return "notFoundTodo"
        case .todoIdValidationError:
            return "todoIdValidationError"
        case .todoValidationError:
            return "todoValidationError"
        }
    }

    var status: HTTPResponseStatus {
        switch self {
        case .notFoundTodo:
            return .notFound
        case .todoIdValidationError:
            return .badRequest
        case .todoValidationError:
            return .badRequest
        }
    }

    var reason: String {
        switch self {
        case .notFoundTodo:
            return "Todoが見つかりませんでした。"
        case .todoIdValidationError:
            return "idの形式が不正です"
        case .todoValidationError:
            return "todoの形式が不正です"
        }
    }
    
    var code: Int {
        switch self {
        case .notFoundTodo:
            return 100
        case .todoIdValidationError:
            return 101
        case .todoValidationError:
            return 102
        }
    }
    
}
