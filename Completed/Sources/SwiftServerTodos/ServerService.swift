import OpenAPIVapor
import ServiceLifecycle
import Vapor

func configureServer(_ app: Application) async throws -> ServerService {
    app.middleware.use(RequestLoggerInjectionMiddleware())

    // A health endpoint.
    app.get("health") { _ in
        "ok\n"
    }

    // Create app state.
    let handler = APIHandler(db: app.db)
    
    // Register the generated handlers.
    let transport = VaporTransport(routesBuilder: app)
    try handler.registerHandlers(
        on: transport,
        serverURL: Servers.Server1.url()
    )
    
    return ServerService(app: app)
}

struct ServerService: Service {
    var app: Application
    func run() async throws {
        try await app.execute()
    }
}
