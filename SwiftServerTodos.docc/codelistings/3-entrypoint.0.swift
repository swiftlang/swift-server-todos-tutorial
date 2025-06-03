import ServiceLifecycle
import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()

        // Configure telemetry
        try await configureTelemetryServices(env: &env)

        // Create the server
        let app = try await Vapor.Application.make()
        app.http.server.configuration.address = .hostname(
            getOptionalEnvVar("SERVER_ADDRESS") ?? "0.0.0.0",
            port: try getOptionalEnvVar("SERVER_PORT") ?? 8080
        )

        // Exercise: configure the database

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
