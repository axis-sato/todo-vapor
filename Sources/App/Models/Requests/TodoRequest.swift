//
//  TodoRequest.swift
//  App
//
//  Created by Masahiko Sato on 2018/10/27.
//

import Foundation
import Vapor

struct TodoRequest: Codable {
    var title: String
    var detail: String?
    var done: Bool
}

extension TodoRequest: Validatable, Content {
    
    public static func decode(from req: Request) throws -> Future<TodoRequest> {
        let content = try req.content.decode(TodoRequest.self)
        return content
    }
    
    static func validations() throws -> Validations<TodoRequest> {
        var validations = Validations(TodoRequest.self)
        validations.add(\TodoRequest.title, at: ["title"], .count(1...))
        return validations
    }
}
