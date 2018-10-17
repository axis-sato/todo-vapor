//
//  TodoService.swift
//  App
//
//  Created by Masahiko Sato on 2018/09/27.
//

import Foundation
import Vapor

protocol TodoServiceType {
    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]>
}


final class TodoService {
    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]> {
        return Todo.query(on: conn).sort(\.id, .ascending).all()
    }
}

extension TodoService: TodoServiceType {}

extension TodoService: ServiceType {
    static var serviceSupports: [Any.Type] {
        return [TodoServiceType.self]
    }
    static func makeService(for worker: Container) throws -> TodoService {
        return TodoService()
    }
}
