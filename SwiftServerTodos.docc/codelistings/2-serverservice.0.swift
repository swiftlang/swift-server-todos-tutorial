import OpenAPIVapor
import ServiceLifecycle
import Vapor

func configureServer(_ app: Application) async throws -> ServerService {
    app.middleware.use(RequestLoggerInjectionMiddleware())

    // A health endpoint.
    app.get("health") { _ in
        "ok\n"
    }

    return ServerService(app: app)
}

struct ServerService: Service {
    var app: Application
    func run() async throws {
        try await app.execute()
    }
}
