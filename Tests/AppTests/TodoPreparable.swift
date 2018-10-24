//
//  TodoPreparable.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/24.
//

@testable import App
import Foundation
import FluentSQLite

protocol TodoPreparable {
    func prepareTodos(on conn: SQLiteConnection)
}

extension TodoPreparable {
    func prepareTodos(on conn: SQLiteConnection) {
        [
            Todo(title: "title1", detail: "detail1"),
            Todo(title: "title2", done: true)
            ].forEach { todo in
                _ = todo.save(on: conn)
        }
    }
}
