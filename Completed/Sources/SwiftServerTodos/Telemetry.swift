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
    let level =
        config.scoped(to: "log")
        .string(forKey: "level")
        .flatMap { Logger.Level.init(rawValue: $0) } ?? .info

    // Logs, metrics, and traces are exported via OpenTelemetry (OTLP).
    // The OTel diagnostic logger stays at its default (stderr) for `makeLoggingBackend`.
    var otelConfig = OTel.Configuration.default
    otelConfig.serviceName = "SwiftServerTodos"

    // Create the OTel logging backend first.
    let otelLoggingBackend = try OTel.makeLoggingBackend(configuration: otelConfig)

    // Fan logs out to both the Vapor console logger and the OTel exporter.
    // The OTel metadata provider attaches `trace_id` and `span_id` from the
    // active span, so logs emitted during a traced request can be correlated
    // with their trace in Grafana.
    let otelMetadataProvider = OTel.makeLoggingMetadataProvider()
    @Sendable
    func makeLogHandler(label: String) -> MultiplexLogHandler {
        MultiplexLogHandler(
            [
                ConsoleLogger(label: label, console: Terminal(), level: level),
                otelLoggingBackend.factory(label),
            ],
            metadataProvider: otelMetadataProvider
        )
    }

    let logger = Logger(label: "SwiftServerTodos", factory: makeLogHandler)

    // Route OTel's own diagnostic logs through the
    // same multiplexed logger, so they also reach OTLP.
    otelConfig.diagnosticLogger = .custom(logger)

    // Create the remaining OTel backends.
    let otelMetricsBackend = try OTel.makeMetricsBackend(configuration: otelConfig)
    let otelTracingBackend = try OTel.makeTracingBackend(configuration: otelConfig)

    // Bootstrap the global logging system too, as a fallback for any `Logger`
    // created without going through the root logger above (for example, by
    // third-party code). Tag those log lines `scope: global` so they're easy
    // to tell apart from the ones that flow through the task-local root logger.
    LoggingSystem.bootstrap { label in
        var handler = makeLogHandler(label: label)
        handler[metadataKey: "scope"] = "global"
        return handler
    }

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
            otelLoggingBackend.service,
            otelMetricsBackend.service,
            otelTracingBackend.service,
            systemMetricsMonitor,
        ],
        logger: logger
    )

    return (logger, telemetryService)
}

struct RequestLoggerInjectionMiddleware: Vapor.AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        try await withLogger(request.logger) { _ in
            try await next.respond(to: request)
        }
    }
}
