import Configuration
import ServiceLifecycle
import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        let config = ConfigReader(provider: EnvironmentVariablesProvider())

        // Configure telemetry
        let (logger, telemetryService) = try await configureTelemetry(config)

        // Bind the logger to the task-local context so that code further down the
        // call stack can read it via `Logger.current` without threading it through.
        try await withLogger(logger) { logger in
            // Create the server
            let serverConfig = config.scoped(to: "address")
            let app = try await Vapor.Application.make(logger: logger)
            app.http.server.configuration.address = .hostname(
                serverConfig.string(forKey: "address", default: "0.0.0.0"),
                port: serverConfig.int(forKey: "port", default: 8080)
            )

            // Configure the database
            try await configureDatabase(app: app, config: config)

            // Configure the server
            let serverService = try await configureServer(app)

            // Services start in array order and shut down in reverse.
            let services: [Service] = [telemetryService, serverService]
            let serviceGroup = ServiceGroup(
                services: services,
                gracefulShutdownSignals: [.sigint],
                cancellationSignals: [.sigterm]
            )
            try await serviceGroup.run()
        }
    }
}
