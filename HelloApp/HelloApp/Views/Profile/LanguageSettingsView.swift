import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case ru = "ru"
    case en = "en"
    var id: String { rawValue }
}

struct LanguageSettingsView: View {
    // храним выбор
    @AppStorage("appLanguage") private var appLanguageRaw: String = "ru"

    private var selected: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .ru
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Русский
                    Button {
                        appLanguageRaw = AppLanguage.ru.rawValue
                    } label: {
                        HStack {
                            Text("russian") // "русский" / "russian"
                                .font(.custom("EB Garamond", size: 18))
                            Spacer()
                            Image(systemName: selected == .ru ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected == .ru ? .blue : .secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // English
                    Button {
                        appLanguageRaw = AppLanguage.en.rawValue
                    } label: {
                        HStack {
                            Text("english") // "английский" / "english"
                                .font(.custom("EB Garamond", size: 18))
                            Spacer()
                            Image(systemName: selected == .en ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selected == .en ? .blue : .secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("coming_soon") 
                        .font(.custom("EB Garamond", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("interface_language_title") 
                        .font(.custom("EB Garamond", size: 27))
                        .fontWeight(.semibold)
                        .padding(.top, 19)
                }
            }
        }
        // если хочешь, чтобы именно этот экран сразу переключал язык своих строк:
        .environment(\.locale, Locale(identifier: appLanguageRaw))
    }
}
#Preview { LanguageSettingsView() }
