import Foundation

struct FavoritePayload: Codable {
    let user_id: Int
    let artwork_id: Int
}

final class FavoriteService {
    static let shared = FavoriteService()
    private init() {}
    
    func fetchFavorites(userID: Int) async throws -> [FavoriteAPIModel] {
        guard let url = URL(string: "\(API.baseURL)/favorites?user_id=\(userID)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoded = try JSONDecoder().decode([FavoriteAPIModel].self, from: data)
        return decoded
    }
    
    func addFavorite(userID: Int, artworkID: Int) async throws {
        guard let url = URL(string: "\(API.baseURL)/favorites/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["user_id": userID, "artwork_id": artworkID]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    func removeFavorite(userID: Int, artworkID: Int) async throws {
        let payload = FavoritePayload(user_id: userID, artwork_id: artworkID)
        guard let url = URL(string: "\(API.baseURL)/favorites?user_id=\(userID)") else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.httpBody = try JSONEncoder().encode(payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.cannotParseResponse)
        }
    }
    
    struct IsFavoriteResponse: Decodable {
        let is_favorite: Bool
    }

    func isFavorite(userID: Int, artworkID: Int) async throws -> Bool {
        guard let url = URL(string: "\(API.baseURL)/favorites/check?user_id=\(userID)&artwork_id=\(artworkID)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(IsFavoriteResponse.self, from: data)
        return decoded.is_favorite
    }
}
