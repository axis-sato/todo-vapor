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
