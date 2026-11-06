import SwiftUI

struct LanguageSensitiveView<Content: View>: View {
    @AppStorage("appLanguage") private var appLanguage = "ru"
    let content: () -> Content

    var body: some View {
        content()
            .id(appLanguage)
    }
}
