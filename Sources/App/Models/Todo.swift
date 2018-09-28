import FluentSQLite
import Vapor

/// A single entry of a Todo list.
final class Todo: SQLiteModel {
    var id: Int?
    var title: String
    var detail: String?
    var done: Bool

    init(id: Int? = nil, title: String, detail: String? = nil, done: Bool = false) {
        self.id = id
        self.title = title
        self.detail = detail
        self.done = done
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }
