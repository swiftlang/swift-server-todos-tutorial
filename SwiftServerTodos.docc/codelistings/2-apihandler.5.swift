import Foundation
import OpenAPIRuntime

struct APIHandler: APIProtocol {
    func listTODOs(
        _ input: Operations.ListTODOs.Input
    ) async throws -> Operations.ListTODOs.Output {
        .undocumented(statusCode: 500, .init())
    }

    func createTODO(
        _ input: Operations.CreateTODO.Input
    ) async throws -> Operations.CreateTODO.Output {
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
