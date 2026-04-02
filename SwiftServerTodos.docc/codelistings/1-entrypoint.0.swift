import Configuration
import ServiceLifecycle
import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        let config = ConfigReader(provider: EnvironmentVariablesProvider())

        // Configure telemetry
        try await configureTelemetryServices(config)

        // Create the server
        let serverConfig = config.scoped(to: "address")
        let app = try await Vapor.Application.make()
        app.http.server.configuration.address = .hostname(
            serverConfig.string(forKey: "address", default: "0.0.0.0"),
            port: serverConfig.int(forKey: "port", default: 8080)
        )

        // Configure the server
        let serverService = try await configureServer(app)

        // Start the service group, which spins up all the service above
        let services: [Service] = [serverService]
        let serviceGroup = ServiceGroup(
            services: services,
            gracefulShutdownSignals: [.sigint],
            cancellationSignals: [.sigterm],
            logger: app.logger
        )
        try await serviceGroup.run()
    }
}
