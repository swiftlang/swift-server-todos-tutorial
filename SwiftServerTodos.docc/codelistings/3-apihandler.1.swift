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
        // Exercise:
        // 0. uncomment switch condition
        // switch input.body {
        // case .json(let todo):

        // 1. Create new ID string using UUID
        // https://developer.apple.com/documentation/foundation/uuid/uuidstring

        // 2. Instantiate a new TODO object from the database with DB.TODO().
        //    Populate the fields (id and contents)

        // 3. Save the value
        
        // 4. Uncomment to return the response
        // return .created(.init(body: .json(.init(
        //     id: newId,
        //     contents: contents
        // ))))
        // }

        // Exercise: Remove this after above logic is completed
        .undocumented(statusCode: 500, .init())
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

