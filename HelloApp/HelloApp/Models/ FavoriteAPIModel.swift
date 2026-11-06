import Foundation

struct FavoriteAPIModel: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let artwork_id: Int
}
