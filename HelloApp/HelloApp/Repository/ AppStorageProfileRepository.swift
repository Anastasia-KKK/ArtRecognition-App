import SwiftUI
import Foundation

// Протокол
protocol ProfileRepository {
    func load() async throws -> UserProfile
    func save(_ data: UserProfile) async throws
    func clear() async throws
    func updatePassword(current: String, new: String) async throws
}

// Ключи
private enum ProfileKeys {
    static let id        = "profile_id"
}

// Минимальная реализация
final class AppStorageProfileRepository: ProfileRepository {
    
    func getUserID() -> Int? {
        let id = UserDefaults.standard.integer(forKey: ProfileKeys.id)
        return id != 0 ? id : nil
    }

    func load() async throws -> UserProfile {
        throw NSError(domain: "NotImplemented", code: -1, userInfo: nil)
    }

    func save(_ data: UserProfile) async throws {
        UserDefaults.standard.set(data.id, forKey: ProfileKeys.id)
    }

    func clear() async throws {
        UserDefaults.standard.removeObject(forKey: ProfileKeys.id)
    }
    
    func updatePassword(current: String, new: String) async throws {
        // Заглушка — в локальном режиме смена пароля не требуется
    }
}
