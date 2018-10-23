//
//  CustomError.swift
//  App
//
//  Created by Masahiko Sato on 2018/10/23.
//
import Vapor

enum CustomError: AbortError {
    case notFoundTodo
    
    var identifier: String {
        switch self {
        case .notFoundTodo:
            return "notFoundTodo"
        }
    }

    var status: HTTPResponseStatus {
        switch self {
        case .notFoundTodo:
            return .notFound
        }
    }

    var reason: String {
        switch self {
        case .notFoundTodo:
            return "Todoが見つかりませんでした。"
        }
    }
    
}
