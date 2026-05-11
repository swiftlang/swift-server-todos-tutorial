import Configuration
import Foundation
import Logging
import Vapor

func configureTelemetry(_ config: ConfigReader) async throws {
    let level = config.scoped(to: "log")
        .string(forKey: "level")
        .flatMap { Logger.Level.init(rawValue: $0) } ?? .info
    LoggingSystem.bootstrap { label in
        ConsoleLogger(label: label, console: Terminal(), level: level)
    }
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
