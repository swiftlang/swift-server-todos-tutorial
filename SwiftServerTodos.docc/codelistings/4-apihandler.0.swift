import Fluent
import Foundation
import HTTPTypes
import Logging
import OpenAPIRuntime

struct APIHandler: APIProtocol {

    var db: Database

    func listTODOs(
        _ input: Operations.ListTODOs.Input
    ) async throws -> Operations.ListTODOs.Output {
        try Logger.current.info("Listing TODOs")

        let dbTodos = try await db.query(DB.TODO.self).all()

        let apiTodos = try dbTodos.map { todo in
            Components.Schemas.TODODetail(
                id: try todo.requireID(),
                contents: todo.contents
            )
        }

        return .ok(.init(body: .json(.init(items: apiTodos))))
    }

    func createTODO(
        _ input: Operations.CreateTODO.Input
    ) async throws -> Operations.CreateTODO.Output {
        switch input.body {
        case .json(let todo):
            let newId = UUID().uuidString
            let contents = todo.contents

            try Logger.current.info(
                "Creating TODO",
                metadata: ["todo.id": "\(newId)"]
            )

            let dbTodo = DB.TODO()
            dbTodo.id = newId
            dbTodo.contents = contents

            try await dbTodo.save(on: db)

            return .created(
                .init(
                    body: .json(
                        .init(
                            id: newId,
                            contents: contents
                        )
                    )
                )
            )
        }
    }

    func getTODODetail(
        _ input: Operations.GetTODODetail.Input
    ) async throws -> Operations.GetTODODetail.Output {
        .undocumented(statusCode: 500, .init())
    }

    func deleteTODO(
        _ input: Operations.DeleteTODO.Input
    ) async throws -> Operations.DeleteTODO.Output {
        .undocumented(statusCode: 500, .init())
    }
}
