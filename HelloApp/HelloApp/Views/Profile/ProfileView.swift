import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showLogin = false
   
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    HStack(alignment: .center, spacing: 16) {
                        profileVM.avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 6) {
                            Text(profileVM.data.name)
                                .font(.custom("EB Garamond", size: 30))
                                .fontWeight(.medium)

                            Text(profileVM.data.email)
                                .font(.custom("EB Garamond", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .lineLimit(1)                
                                .truncationMode(.tail)

                            NavigationLink {
                                EditProfileView()
                            } label: {
                                Text("Edit profile")
                                    .font(.custom("EB Garamond", size: 16))
                                    .fontWeight(.medium)
                                    .foregroundColor(.black)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 24)
                                    .background(Color(.systemGray6).opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            .padding(.top, 4)
                            .task { await profileVM.load() }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal)

                    SettingsGroup {
                        NavigationLink{
                            FavoritesView()
                        } label: {
                            SettingsRow(icon: "heart", titleKey: "Избранное")
                            // push Favorites
                        }
                        
                        NavigationLink{
                            SearchHistoryView()
                        }label: {
                            SettingsRow(icon: "magnifyingglass", titleKey: "История поиска")
                            // push Search History
                        }
                       
                        
                        NavigationLink{
                            LanguageSettingsView()
                        } label: {
                            SettingsRow(icon: "globe", titleKey: "Язык интерфейса")
                        }
                        
                        

                        SettingsRow(icon: "questionmark.circle", titleKey: "Help Center")
                        // push Help
                        
                    }

                    Button {
                        showLogin = true
                    } label: {
                        Text("Log out")
                            .font(.custom("EB Garamond", size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 150)
                            .background(Color(.systemGray6).opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .fullScreenCover(isPresented: $showLogin) {
                        LoginView()
                            .environmentObject(profileVM)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


struct SettingsGroup<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 15) {
            content
        }
        .padding(.horizontal, 16)
    }
}

struct SettingsRow: View {
    let icon: String
    let titleKey: LocalizedStringKey
    
    var body: some View {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .imageScale(.large)

                Text(titleKey)
                    .font(.custom("EB Garamond", size: 20))
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        
        .background(Color.clear)
        .overlay(
            VStack {
                Spacer()
                Rectangle().fill(Color(.systemGray5)).frame(height: 1)
            }
                .padding(.leading, 16)
                .opacity(0.9)
        )
    }
}
