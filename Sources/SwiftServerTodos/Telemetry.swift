import Foundation
import Logging
import Vapor

func configureTelemetryServices(env: inout Environment) async throws {
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
