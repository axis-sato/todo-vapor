//
//  TodoServiceTest.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/17.
//
@testable import App
import XCTest
import Vapor
import FluentSQLite

final class TodoServiceTests: BaseTestCase {
    
    var todoService: TodoServiceType!
    var conn: SQLiteConnection!
    
    override func setUp() {
        super.setUp()
        conn = try! app.newConnection(to: .sqlite).wait()
        todoService = try! app.make(TodoServiceType.self)
    }

    func testRetrieveAllTodos() throws {
        prepareTodos()

        let todos = try todoService.retrieveAllTodos(on: conn).wait()
        
        XCTAssertEqual(2, todos.count, "全件取得できること")
        
        XCTAssertEqual("title1", todos[0].title)
        XCTAssertEqual("detail1", todos[0].detail)
        XCTAssertFalse(todos[0].done)
        
        XCTAssertEqual("title2", todos[1].title)
        XCTAssertEqual(nil, todos[1].detail)
        XCTAssertTrue(todos[1].done)
    }
    
    func testRetrieveTodo() throws {
        prepareTodos()
        
        let todo1 = try todoService.retrieveTodo(id: 1, on: conn).wait()
        XCTAssertEqual("title1", todo1.title)
        XCTAssertEqual("detail1", todo1.detail)
        
        let todo2 = try todoService.retrieveTodo(id: 2, on: conn).wait()
        XCTAssertEqual("title2", todo2.title)
        XCTAssertEqual(nil, todo2.detail)
    }
    
    func testRetrieveTodo_idが不正な場合例外を投げること() throws {
        prepareTodos()

        XCTAssertThrowsError(try todoService.retrieveTodo(id: 3, on: conn).wait()) { error in
            XCTAssertEqual(error as? CustomError, CustomError.notFoundTodo)
        }
    }
    
    
    private func prepareTodos() {
        [
            Todo(title: "title1", detail: "detail1"),
            Todo(title: "title2", done: true)
            ].forEach { todo in
                _ = todo.save(on: conn)
        }
    }

    override func tearDown() {
        super.tearDown()
        conn.close()
    }
}
