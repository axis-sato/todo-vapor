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
    router.get("todo", Int.parameter, use: todoController.showTodo)
    router.post("todos", use: todoController.createTodo)
    router.delete("todos", Todo.parameter, use: todoController.delete)
}
