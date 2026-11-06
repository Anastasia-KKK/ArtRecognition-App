import SwiftUI

import Foundation

struct UserProfile: Codable, Identifiable {
    var id: Int
    var name: String
    var email: String
    var language: String
    var avatarData: Data?

    enum CodingKeys: String, CodingKey {
        case id, name, email, language
        case avatarData = "photo"
    }
}
