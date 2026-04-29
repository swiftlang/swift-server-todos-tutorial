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
    // Logs stay in the console — configure the Vapor console logger.
    let level = config.scoped(to: "log")
        .string(forKey: "level")
        .flatMap { Logger.Level.init(rawValue: $0) } ?? .info
    LoggingSystem.bootstrap { label in
        ConsoleLogger(label: label, console: Terminal(), level: level)
    }

    let logger = Logger(label: "SwiftServerTodos")

    // Metrics and traces are exported via OpenTelemetry (OTLP).
    var otelConfig = OTel.Configuration.default
    otelConfig.logs.enabled = false
    otelConfig.serviceName = "SwiftServerTodos"
    otelConfig.diagnosticLogger = .custom(logger)

    // Create separate metrics and tracing backends.
    let otelMetricsBackend = try OTel.makeMetricsBackend(configuration: otelConfig)
    let otelTracingBackend = try OTel.makeTracingBackend(configuration: otelConfig)

    // Register the metrics and tracing backends globally.
    MetricsSystem.bootstrap(otelMetricsBackend.factory)
    InstrumentationSystem.bootstrap(otelTracingBackend.factory)

    // Collect system-level metrics (CPU, memory, file descriptors, etc.).
    let systemMetricsMonitor = SystemMetricsMonitor(
        metricsFactory: otelMetricsBackend.factory,
        logger: logger
    )

    // Combine all OTel services so they start and stop together.
    let telemetryService = ServiceGroup(
        services: [
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
