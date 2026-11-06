import SwiftUI
import Foundation

final class RemoteProfileRepository: ProfileRepository {
    func load() async throws -> UserProfile {
        guard let userID = AppStorageProfileRepository().getUserID() else {
            throw URLError(.badURL)
        }

        guard let url = URL(string: "\(API.baseURL)/auth/me?user_id=\(userID)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
        return decoded
    }

    func save(_ data: UserProfile) async throws {
            guard let url = URL(string: "\(API.baseURL)/users/\(data.id)") else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(data)

            _ = try await URLSession.shared.data(for: request)
        }

        func clear() async throws {}

        
        func updatePassword(current: String, new: String) async throws {
            guard let url = URL(string: "\(API.baseURL)/users/change-password") else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "user_id": AppStorageProfileRepository().getUserID()!,
                "current_password": current,
                "new_password": new
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)

            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                throw URLError(.badServerResponse)
            }
        }
    }

