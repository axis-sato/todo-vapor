import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class TodoController {

    func showTodos(_ req: Request) throws -> Future<[Todo]> {
        let todoService = try req.make(TodoServiceType.self)
        return todoService.retrieveAllTodos(on: req)
    }
    
    func showTodo(_ req: Request) throws -> Future<Todo> {
        let todoService = try req.make(TodoServiceType.self)
        guard let id = try? req.parameters.next(Int.self) else {
            throw CustomError.todoIdValidationError
        }
        return try todoService.retrieveTodo(id: id, on: req)
    }

    func createTodo(_ req: Request, request: TodoRequest) throws -> Future<[Todo]> {
        let todoService = try req.make(TodoServiceType.self)
        
        do {
            try request.validate()
        } catch {
            throw CustomError.todoValidationError
        }

        return try todoService.createTodo(request, on: req)
    }

    func editTodo(_ req: Request, request: TodoRequest) throws -> Future<[Todo]> {
        let todoService = try req.make(TodoServiceType.self)
        
        guard let id = try? req.parameters.next(Int.self) else {
            throw CustomError.todoIdValidationError
        }
        
        do {
            try request.validate()
        } catch {
            throw CustomError.todoValidationError
        }
        
        return try todoService.editTodo(request, id: id, on: req)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
