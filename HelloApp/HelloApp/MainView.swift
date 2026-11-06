import SwiftUI

struct MainView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                }

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                }

            RecognitionView()
                .tabItem {
                    Image(systemName: "viewfinder")
                }

            ProfileView() 
                .tabItem {
                    Image(systemName: "person")
                }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

