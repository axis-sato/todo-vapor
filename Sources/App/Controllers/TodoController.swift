import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {

    func showTodos(_ req: Request) throws -> Future<[Todo]> {
        let todoService = try req.make(TodoServiceType.self)
        return todoService.retrieveAllTodos(on: req)
    }

    /// Saves a decoded `Todo` to the database.
    func createTodo(_ req: Request) throws -> Future<Todo> {
        return try req.content.decode(Todo.self).flatMap { todo in
            return todo.save(on: req)
        }
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
