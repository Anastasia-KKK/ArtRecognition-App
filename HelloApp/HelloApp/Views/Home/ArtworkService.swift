import Foundation

class ArtworkService {
    static let shared = ArtworkService()

    func fetchAllArtworks(completion: @escaping ([ArtworkAPIModel]) -> Void) {
        guard let url = URL(string: "\(API.baseURL)/artworks") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode([ArtworkAPIModel].self, from: data)
                DispatchQueue.main.async {
                    completion(decoded)
                }
            } catch {
                print("Ошибка при декодировании: \(error)")
                completion([])
            }
        }.resume()
    }
    func fetchArtwork(by id: Int) async throws -> ArtworkAPIModel {
        guard let url = URL(string: "\(API.baseURL)/artworks/\(id)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(ArtworkAPIModel.self, from: data)
        return decoded
    }
}
