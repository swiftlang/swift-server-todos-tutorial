import Fluent
import HTTPTypes
import Foundation
import OpenAPIRuntime

struct APIHandler: APIProtocol {
    
    var db: Database
    
    func listTODOs(
        _ input: Operations.ListTODOs.Input
    ) async throws -> Operations.ListTODOs.Output {
        // Exercise:
        // 1. Fetch todos from database
        let dbTodos = try await db.query(DB.TODO.self).all()
        
        // 2. Serialize them to the TODO Detail array
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

