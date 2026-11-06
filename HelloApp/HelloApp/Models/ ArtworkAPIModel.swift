import Foundation

struct ArtworkAPIModel: Identifiable, Decodable {
    let id: Int
    let title: String
    let title_en: String?      
    let author: AuthorAPIModel?
    let year: String?
    let material: String?
    let material_en: String?
    let size: String?
    let size_en: String?
    let description: String?
    let description_en: String?
    let creation_history: String?
    let creation_history_en: String?
    let image: String
}
