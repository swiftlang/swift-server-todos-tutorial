import Fluent
import FluentPostgresDriver
import Foundation
import Vapor

enum DB {
    final class TODO: Model, @unchecked Sendable {
        static let schema = "todos"

        @ID(custom: "id", generatedBy: .user)
        var id: String?

        @Field(key: "contents")
        var contents: String
    }
}

enum Migrations {
    struct CreateTODOs: AsyncMigration {
        func prepare(on database: Database) async throws {
            // Exercise: add table creation logic
        }
        
        func revert(on database: Database) async throws {
            // Exercise: add table deletion logic
        }
    }
}
