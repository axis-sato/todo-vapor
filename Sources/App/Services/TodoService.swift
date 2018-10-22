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
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) -> Future<Todo?>
}


final class TodoService {}

extension TodoService: TodoServiceType {
    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]> {
        return Todo.query(on: conn).sort(\.id, .ascending).all()
    }
    
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) -> EventLoopFuture<Todo?> {
        return Todo.find(id, on: conn)
    }
}

extension TodoService: ServiceType {
    static var serviceSupports: [Any.Type] {
        return [TodoServiceType.self]
    }
    static func makeService(for worker: Container) throws -> TodoService {
        return TodoService()
    }
}
