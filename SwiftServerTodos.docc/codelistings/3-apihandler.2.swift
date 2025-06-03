import Fluent
import HTTPTypes
import Foundation
import OpenAPIRuntime

struct APIHandler: APIProtocol {
    
    var db: Database
    
    func listTODOs(
        _ input: Operations.ListTODOs.Input
    ) async throws -> Operations.ListTODOs.Output {
        .undocumented(statusCode: 500, .init())
    }

    func createTODO(
        _ input: Operations.CreateTODO.Input
    ) async throws -> Operations.CreateTODO.Output {
        switch input.body {
        case .json(let todo):
            // 1. Create new ID string using UUID
            let newId = UUID().uuidString
            let contents = todo.contents

            // 2. Instantiate a new TODO object from the database with DB.TODO()
            //    Populate the fields (id and contents)
            let dbTodo = DB.TODO()
            dbTodo.id = newId
            dbTodo.contents = contents

            // 3. Save the value
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

