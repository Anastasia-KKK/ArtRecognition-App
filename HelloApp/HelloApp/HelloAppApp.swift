import SwiftUI

@main
struct HelloAppApp: App {
    @AppStorage("appLanguage") private var appLanguage = "ru"
    @StateObject private var profileVM = ProfileViewModel(repo: RemoteProfileRepository())
    init() {
            if CommandLine.arguments.contains("-reset-state") {
                UserDefaults.standard.removePersistentDomain(
                    forName: Bundle.main.bundleIdentifier!
                )
            }
        }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootContainerView() 
            }
            .environment(\.locale, Locale(identifier: appLanguage))
            .environmentObject(profileVM)
        }
    }
}
