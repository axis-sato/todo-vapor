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
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) throws -> Future<Todo>
    func createTodo(_ request: TodoRequest, on conn: DatabaseConnectable) throws -> Future<[Todo]>
    func editTodo(_ request: TodoRequest, id: Int, on conn: DatabaseConnectable) throws -> Future<[Todo]>
    func deleteTodo(id: Int, on conn: DatabaseConnectable) throws -> Future<[Todo]>
}


final class TodoService {}

extension TodoService: TodoServiceType {

    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]> {
        return Todo.query(on: conn).sort(\.id, .ascending).all()
    }
    
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) throws -> EventLoopFuture<Todo> {
        let todo = Todo.find(id, on: conn).map(to: Todo.self) { todo in
            guard let t = todo else {
                throw CustomError.notFoundTodo
            }
            return t
        }

        return todo
    }
    
    func createTodo(_ request: TodoRequest, on conn: DatabaseConnectable) throws -> EventLoopFuture<[Todo]> {
        let todo = Todo(title: request.title, detail: request.detail, done: request.done)
        return todo.create(on: conn).flatMap { _ in
            return self.retrieveAllTodos(on: conn)
        }
    }
    
    func editTodo(_ request: TodoRequest, id: Int, on conn: DatabaseConnectable) throws -> EventLoopFuture<[Todo]> {
        
        return try retrieveTodo(id: id, on: conn)
            .flatMap(to: Todo.self) { todo in
                todo.title = request.title
                todo.detail = request.detail
                todo.done = request.done
                return todo.update(on: conn)
            }
            .flatMap(to: [Todo].self) { _ in
                return self.retrieveAllTodos(on: conn)
        }
    }
    
    func deleteTodo(id: Int, on conn: DatabaseConnectable) throws -> EventLoopFuture<[Todo]> {
        return try retrieveTodo(id: id, on: conn)
            .flatMap { todo in
                todo.delete(on: conn)
            }
            .flatMap(to: [Todo].self) { _ in
                return self.retrieveAllTodos(on: conn)
        }
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
