import Foundation
import Vapor

struct Todo: Identifiable, Content {
    var id = UUID()
    let contents: String
}
