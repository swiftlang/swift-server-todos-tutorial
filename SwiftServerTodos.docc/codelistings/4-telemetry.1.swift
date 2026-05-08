import Configuration
import Foundation
import Logging
import Metrics
import OTel
import ServiceLifecycle
import SystemMetrics
import Tracing
import Vapor

func configureTelemetry(_ config: ConfigReader) async throws -> (Logger, some Service) {
    let level = config.scoped(to: "log")
        .string(forKey: "level")
        .flatMap { Logger.Level.init(rawValue: $0) } ?? .info

    // Logs, metrics, and traces are exported via OpenTelemetry (OTLP).
    // The OTel diagnostic logger is left as default (stderr) so OTel's own
    // internal logs don't recurse back through the multiplexed handler below.
    var otelConfig = OTel.Configuration.default
    otelConfig.serviceName = "SwiftServerTodos"

    // Create the OTel backends.
    let otelLoggingBackend = try OTel.makeLoggingBackend(configuration: otelConfig)
    let otelMetricsBackend = try OTel.makeMetricsBackend(configuration: otelConfig)
    let otelTracingBackend = try OTel.makeTracingBackend(configuration: otelConfig)

    // Fan logs out to both the Vapor console logger and the OTel exporter.
    LoggingSystem.bootstrap { label in
        MultiplexLogHandler([
            ConsoleLogger(label: label, console: Terminal(), level: level),
            otelLoggingBackend.factory(label),
        ])
    }
    MetricsSystem.bootstrap(otelMetricsBackend.factory)
    InstrumentationSystem.bootstrap(otelTracingBackend.factory)

    let logger = Logger(label: "SwiftServerTodos")

    // Collect system-level metrics (CPU, memory, file descriptors, etc.).
    let systemMetricsMonitor = SystemMetricsMonitor(
        metricsFactory: otelMetricsBackend.factory,
        logger: logger
    )

    // Combine all OTel services so they start and stop together.
    let telemetryService = ServiceGroup(
        services: [
            otelLoggingBackend.service,
            otelMetricsBackend.service,
            otelTracingBackend.service,
            systemMetricsMonitor,
        ], logger: logger)

    return (logger, telemetryService)
}

extension Logger {
    @TaskLocal
    static var _current: Logger?

    static var current: Logger {
        get throws {
            guard let _current else {
                struct NoCurrentLoggerError: Error {}
                throw NoCurrentLoggerError()
            }
            return _current
        }
    }
}

struct RequestLoggerInjectionMiddleware: Vapor.AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        try await Logger.$_current.withValue(request.logger) {
            try await next.respond(to: request)
        }
    }
}
