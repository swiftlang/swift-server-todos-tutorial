import Fluent
import FluentPostgresDriver
import Foundation
import Vapor

func configureDatabase(app: Application) async throws {
    let postgresURL = try getOptionalURLEnvVar("POSTGRES_URL")
        ?? URL(string: "postgres://postgres@localhost:5432/postgres?sslmode=disable")!
    try app.databases.use(.postgres(url: postgresURL), as: .psql)

    app.migrations.add([
        Migrations.CreateTODOs()
    ])
    try await app.autoMigrate()
}

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
            try await database.schema(DB.TODO.schema)
                .field("id", .string, .identifier(auto: false))
                .field("contents", .string, .required)
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database
                .schema(DB.TODO.schema)
                .delete()
        }
    }
}
