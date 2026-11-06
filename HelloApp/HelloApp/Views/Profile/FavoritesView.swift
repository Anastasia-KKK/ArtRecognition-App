import SwiftUI

struct FavoritesView: View {
    @State private var artworks: [ArtworkAPIModel] = []
    //private let userID = 5
    @EnvironmentObject var profileVM: ProfileViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if artworks.isEmpty {
                        VStack(spacing: 8) {
                            Text("Здесь пока пусто")
                                .font(.custom("EB Garamond", size: 20))
                            Text("Добавляйте картины в избранное на их странице.")
                                .foregroundColor(.gray)
                                .font(.custom("EB Garamond", size: 16))
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVGrid(columns: columns, alignment: .center, spacing: 28) {
                            ForEach(artworks) { art in
                                NavigationLink {
                                    ArtworkDetailView(artworkID: art.id)
                                } label: {
                                    FavoriteCard(art: art)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Избранное")
                        .font(.custom("EB Garamond", size: 29))
                        .fontWeight(.semibold)
                }
            }
            .task {
                await loadFavorites()
            }
        }
    }

    private func loadFavorites() async {
        do {
            let userID = profileVM.data.id
            guard userID != 0,
                  let url = URL(string: "\(API.baseURL)/favorites?user_id=\(userID)") else { return }

            let (data, _) = try await URLSession.shared.data(from: url)

            let decoded = try JSONDecoder().decode([ArtworkAPIModel].self, from: data)

            await MainActor.run {
                self.artworks = decoded
            }

        } catch {
            print("Ошибка загрузки избранных: \(error)")
        }
     }
}
