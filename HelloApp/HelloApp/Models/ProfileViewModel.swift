import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var data = UserProfile(id: 0, name: "", email: "", language: "ru", avatarData: nil)
    @Published var isLoaded = false

    private let repo: ProfileRepository

    init(repo: ProfileRepository) {
        self.repo = repo
        Task { await load() }
    }

    func load() async {
        if let loaded = try? await repo.load(), loaded.id != 0 {
            await MainActor.run {
                self.data = loaded
            }
        }
        await MainActor.run {
            self.isLoaded = true
        }
    }

    func save() async {
        _ = try? await repo.save(data)
    }

    var avatarImage: Image {
        if let data = data.avatarData,
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return Image("user_photo")
        }
    }

    func setAvatar(_ ui: UIImage?) {
        if let ui, let bytes = ui.pngData() {
            data.avatarData = bytes
        }
    }
    
    func updatePassword(current: String, new: String) async {
           do {
               try await repo.updatePassword(current: current, new: new)
           } catch {
               print("Ошибка смены пароля: \(error)")
           }
       }
}
