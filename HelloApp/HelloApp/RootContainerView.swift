import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject var profileVM: ProfileViewModel

    var body: some View {
        NavigationStack {
            Group {
                if CommandLine.arguments.contains("-ui-testing") {
                    LoginView()
                } else if profileVM.data.id == 0 {
                    LoginView()
                } else {
                    MainView()
                }
            }
        }
    }
}
