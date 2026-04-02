import Configuration
import Foundation
import Logging
import Vapor

func configureTelemetryServices(_ config: ConfigReader) async throws {
    // Vapor's LoggingSystem.bootstrap(from:) detects the log level from CLI args (--log),
    // then falls back to the LOG_LEVEL env var, then to a default based on environment.
    // We inject ConfigReader's value as a middle priority between CLI args and Vapor's
    // env var fallback, so the effective priority is:
    //   1. CLI arg (--log)
    //   2. ConfigReader value (from any provider)
    //   3. Vapor's built-in fallback (LOG_LEVEL env var, then environment default)
    // This is a temporary workaround until Vapor supports swift-configuration natively.
    var env = try Environment.detect()
    let logConfig = config.scoped(to: "log")
    if !env.arguments.contains("--log"), let level = logConfig.string(forKey: "level") {
        env.arguments += ["--log", level]
    }
    try LoggingSystem.bootstrap(from: &env)
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
