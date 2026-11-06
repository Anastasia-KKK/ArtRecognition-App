import SwiftUI

struct ArtworkDetailView: View {
    let artworkID: Int
    
    @State private var artwork: ArtworkAPIModel? = nil
    @State private var isFavorite = false
    @State private var isFullScreen = false
    @State private var didCheckFavorite = false
    
    @Environment(\.dismiss) private var dismiss
    let buttonSize: CGFloat = 44
    @EnvironmentObject var profileVM: ProfileViewModel
    
    var body: some View {
        GeometryReader { geometry in
            if let artwork = artwork {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: URL(string: "\(API.baseURL)/\(artwork.image)")) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: geometry.size.width, height: 300)
                            .clipped()
                            
                            
                            HStack {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(.blue)
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Color.white.opacity(0.7))
                                        .clipShape(Circle())
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    print("Нажата кнопка избранного")
                                    Task {
                                        let userID = profileVM.data.id
                                        if userID == 0 {
                                            print("Профиль не загружен или id = 0")
                                            return
                                        }
                                        
                                        do {
                                            if isFavorite {
                                                try await FavoriteService.shared.removeFavorite(userID: userID, artworkID: artwork.id)
                                                print("Удалено из избранного")
                                            } else {
                                                try await FavoriteService.shared.addFavorite(userID: userID, artworkID: artwork.id)
                                                print("Добавлено в избранное")
                                            }
                                            isFavorite.toggle()
                                        } catch {
                                            print("Ошибка избранного: \(error)")
                                        }
                                    }
                                }) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(isFavorite ? .red : .blue)
                                        .frame(width: buttonSize, height: buttonSize)
                                        .background(Color.white.opacity(0.7))
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 50)
                            
                            .task {
                                guard !didCheckFavorite else { return } // ← предотвращает повторный вызов
                                didCheckFavorite = true
                                
                                let userID = profileVM.data.id
                                guard userID != 0 else {
                                    return
                                }
                                
                                do {
                                    let favorite = try await FavoriteService.shared.isFavorite(userID: userID, artworkID: artwork.id)
                                    isFavorite = favorite
                                } catch {
                                    print("Ошибка при получении статуса избранного: \(error)")
                                }
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button {
                                        withAnimation(.easeInOut) { isFullScreen = true }
                                    } label: {
                                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.blue)
                                            .frame(width: buttonSize, height: buttonSize)
                                            .background(Color.white.opacity(0.7))
                                            .clipShape(Circle())
                                    }
                                    .padding(.bottom, 20)
                                    .padding(.trailing, 20)
                                }
                            }
                            .frame(height: 300)
                        }
                        
                        VStack(spacing: 8) {
                            Text(artwork.title)
                                .font(.custom("EB Garamond", size: 30))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("\(artwork.material ?? "—") | \(artwork.size ?? "—") | \(artwork.year ?? "—")")
                                .font(.custom("EB Garamond", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(artwork.author?.name ?? "Неизвестный автор")
                                .font(.custom("EB Garamond", size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Описание картины")
                                .font(.custom("EB Garamond", size: 22))
                                .fontWeight(.medium)
                            
                            Text(artwork.description ?? "Описание появится позже.")
                                .font(.custom("EB Garamond", size: 18))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("История создания")
                                .font(.custom("EB Garamond", size: 22))
                                .fontWeight(.medium)
                            
                            Text(artwork.creation_history ?? "История появится позже.")
                                .font(.custom("EB Garamond", size: 18))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarBackButtonHidden(true)
                .fullScreenCover(isPresented: $isFullScreen) {
                    ZoomScreen(imageName: artwork.image)
                }
                
            }
        }
        .task {
            await loadArtwork()
        }
    }
    
    private func loadArtwork() async {
        do {
            let loaded = try await ArtworkService.shared.fetchArtwork(by: artworkID)
            artwork = loaded
        } catch {
            print("Ошибка загрузки детали: \(error)")
        }
    }
}
