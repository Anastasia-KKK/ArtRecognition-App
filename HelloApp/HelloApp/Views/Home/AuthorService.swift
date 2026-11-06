import Foundation

final class AuthorService {
    static let shared = AuthorService()

    func fetchAuthors() async throws -> [AuthorAPIModel] {
        guard let url = URL(string: "\(API.baseURL)/authors") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([AuthorAPIModel].self, from: data)
    }
}
