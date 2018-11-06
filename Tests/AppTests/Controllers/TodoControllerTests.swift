//
//  TodoControllerTest.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/24.
//
@testable import App
import XCTest
import Vapor
import FluentSQLite

final class TodoControllerTests: BaseTestCase {
    
    var conn: SQLiteConnection!
    
    override func setUp() {
        super.setUp()
        conn = try! app.newConnection(to: .sqlite).wait()
    }
    
    func testShowTodos() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todos", method: .GET, body: body)
        let todos = try response.content.decode([Todo].self).wait()
        
        XCTAssertEqual(1, todos[0].id)
        XCTAssertEqual("title1", todos[0].title)
        XCTAssertEqual("detail1", todos[0].detail)
        XCTAssertFalse(todos[0].done)
        
        XCTAssertEqual(2, todos[1].id)
        XCTAssertEqual("title2", todos[1].title)
        XCTAssertEqual(nil, todos[1].detail)
        XCTAssertTrue(todos[1].done)
    }
    
    func testShowTodo() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todos/1", method: .GET, body: body)
        let todo = try response.content.decode(Todo.self).wait()
        
        XCTAssertEqual(1, todo.id)
        XCTAssertEqual("title1", todo.title)
        XCTAssertEqual("detail1", todo.detail)
        XCTAssertFalse(todo.done)
    }
    
    func testShowTodo_idが不正な場合status_code400を返すこと() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todo/id", method: .GET, body: body)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 400)
        XCTAssertEqual(errorResponse.code, CustomError.todoIdValidationError.code)
        XCTAssertEqual(errorResponse.message, CustomError.todoIdValidationError.reason)
    }
    
    func testShowTodo_todoが存在しない場合status_code404を返すこと() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todo/3", method: .GET, body: body)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 404)
        XCTAssertEqual(errorResponse.code, CustomError.notFoundTodo.code)
        XCTAssertEqual(errorResponse.message, CustomError.notFoundTodo.reason)
    }
    
    func testCreateTodo() throws {
        
        let todo = TodoRequest(title: "title1", detail: "detail1", done: false)
        let response = try app.sendRequest(to: "/todos", method: .POST, body: todo)
        let todos = try response.content.decode([Todo].self).wait()
        
        XCTAssertEqual(1, todos.count)
        XCTAssertEqual(1, todos[0].id)
        XCTAssertEqual("title1", todos[0].title)
        XCTAssertEqual("detail1", todos[0].detail)
        XCTAssertFalse(todos[0].done)
    }
    
    func testCreateTodo_リクエストbodyが不正な場合status_code400を返すこと() throws {

        let request = TodoRequest(title: "", detail: "detail", done: false)
        let response = try app.sendRequest(to: "/todos", method: .POST, body: request)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 400)
        XCTAssertEqual(errorResponse.code, CustomError.todoValidationError.code)
        XCTAssertEqual(errorResponse.message, CustomError.todoValidationError.reason)
    }
    
    func testEditTodo() throws {
        prepareTodos(on: conn)
        
        let request = TodoRequest(title: "title", detail: "detail", done: true)
        let response = try app.sendRequest(to: "/todos/1", method: .PUT, body: request)
        let todos = try response.content.decode([Todo].self).wait()
        
        XCTAssertEqual(2, todos.count)
        XCTAssertEqual(1, todos[0].id)
        XCTAssertEqual("title", todos[0].title)
        XCTAssertEqual("detail", todos[0].detail)
        XCTAssertTrue(todos[0].done)
    }
    
    func testEditTodo_リクエストbodyが不正な場合status_code400を返すこと() throws {
        
        let request = TodoRequest(title: "", detail: "detail", done: false)
        let response = try app.sendRequest(to: "/todos/1", method: .PUT, body: request)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 400)
        XCTAssertEqual(errorResponse.code, CustomError.todoValidationError.code)
        XCTAssertEqual(errorResponse.message, CustomError.todoValidationError.reason)
    }
    
    func testEditTodo_todoが存在しない場合status_code404を返すこと() throws {
        
        let request = TodoRequest(title: "title", detail: "detail", done: true)
        let response = try app.sendRequest(to: "/todos/1", method: .PUT, body: request)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 404)
        XCTAssertEqual(errorResponse.code, CustomError.notFoundTodo.code)
        XCTAssertEqual(errorResponse.message, CustomError.notFoundTodo.reason)
    }
    
    func testDeleteTodo() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todos/1", method: .DELETE, body: body)
        let todos = try response.content.decode([Todo].self).wait()
        
        XCTAssertEqual(1, todos.count)
        XCTAssertEqual(2, todos[0].id)
        XCTAssertEqual("title2", todos[0].title)
        XCTAssertEqual(nil, todos[0].detail)
        XCTAssertTrue(todos[0].done)
    }
    
    func testDeleteTodo_リクエストが不正な場合status_code400を返すこと() throws {
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todos/aa", method: .DELETE, body: body)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 400)
        XCTAssertEqual(errorResponse.code, CustomError.todoIdValidationError.code)
        XCTAssertEqual(errorResponse.message, CustomError.todoIdValidationError.reason)
    }
    
    func testDeleteTodo_todoが存在しない場合status_code404を返すこと() throws {
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todos/3", method: .DELETE, body: body)
        let errorResponse = try response.content.decode(CustomErrorMiddleware.ErrorResponse.self).wait()
        
        XCTAssertEqual(response.http.status.code, 404)
        XCTAssertEqual(errorResponse.code, CustomError.notFoundTodo.code)
        XCTAssertEqual(errorResponse.message, CustomError.notFoundTodo.reason)
    }
}

extension TodoControllerTests: TodoPreparable {}
