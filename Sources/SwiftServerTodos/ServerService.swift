import ServiceLifecycle
import Vapor

func configureServer(_ app: Application) async throws -> ServerService {
    app.middleware.use(RequestLoggerInjectionMiddleware())

    // A health endpoint.
    app.get("health") { _ in
        "ok\n"
    }

    // A route to list TODOs.
    app.get("todos") { req in
        [
            Todo(contents: "example todo")
        ]
    }

    return ServerService(app: app)
}

struct ServerService: Service {
    var app: Application
    func run() async throws {
        try await app.execute()
    }
}
