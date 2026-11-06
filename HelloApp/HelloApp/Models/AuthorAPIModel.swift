import Foundation

struct AuthorAPIModel: Identifiable, Decodable {
    let id: Int
    let name: String
    let portrait_url: String?
}
