import Configuration
import Metrics
import ServiceLifecycle
import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        let config = ConfigReader(provider: EnvironmentVariablesProvider())

        // Configure telemetry
        let (logger, telemetryService, metricsFactory) = try await configureTelemetry(config)

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

        // Start the service group, which spins up the telemetry and server services
        let services: [Service] = [telemetryService, serverService]
        let serviceGroup = ServiceGroup(
            services: services,
            gracefulShutdownSignals: [.sigint],
            cancellationSignals: [.sigterm],
            logger: logger
        )
        try await withMetricsFactory(metricsFactory) {
            try await serviceGroup.run()
        }
    }
}
