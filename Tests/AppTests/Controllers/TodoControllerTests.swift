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
        let response = try app.sendRequest(to: "/todo/1", method: .GET, body: body)
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
        XCTAssertEqual(response.http.status.code, 400)
    }
    
    func testShowTodo_todoが存在しない場合status_code404を返すこと() throws {
        prepareTodos(on: conn)
        
        let body: EmptyBody? = nil
        let response = try app.sendRequest(to: "/todo/3", method: .GET, body: body)
        XCTAssertEqual(response.http.status.code, 404)
    }
}

extension TodoControllerTests: TodoPreparable {}
