import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.showTodos)
    router.get("todos", Int.parameter, use: todoController.showTodo)
    router.post(TodoRequest.self, at: "todos", use: todoController.createTodo)
    router.put(TodoRequest.self, at: "todos", Int.parameter, use: todoController.editTodo)
    router.delete("todos", Int.parameter, use: todoController.delete)
}
