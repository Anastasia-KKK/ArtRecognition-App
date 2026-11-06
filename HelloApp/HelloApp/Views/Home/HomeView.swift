import SwiftUI

struct HomeView: View {
    @State private var artworks: [ArtworkAPIModel] = []
    @State private var authors: [AuthorAPIModel] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Добро пожаловать")
                            .accessibilityIdentifier("homeTitle")
                            .font(.custom("EB Garamond", size: 28))
                            .bold()
                        
                        Spacer()
                        
                        Image("image1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 45, height: 45)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    
                    Text("Рекомендованные картины")
                        .accessibilityIdentifier("recommendedTitle")
                        .font(.custom("EB Garamond", size: 27))
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.top, 1)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(artworks) { artwork in
                                artworkCard(for: artwork)
                            }
                        }
                    }
                    
                    Text("Известные авторы")
                        .font(.custom("EB Garamond", size: 27))
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.top, 5)
                                        
                    VStack(spacing: 12) {
                        ForEach(authors) { author in
                            AuthorRow(author: author)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 2)
                }
                    .padding(.vertical, 8)
            }
                .task {
                    await loadArtworks()
                    await loadAuthors()
            }
        }
    }
                    

    struct AuthorRow: View {
        let author: AuthorAPIModel

        var body: some View {
            HStack(spacing: 12) {
                AsyncImage(url: author.portrait_url.flatMap { URL(string: $0) }) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(author.name)
                    .font(.custom("EB Garamond", size: 18))
                    .fontWeight(.semibold)
                    .tracking(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
            )
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func loadArtworks() async {
        guard let url = URL(string: "\(API.baseURL)/artworks/") else { return }
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ArtworkAPIModel].self, from: data)
            artworks = decoded
        } catch {
            print("Ошибка загрузки картин: \(error)")
        }
    }
    
    private func loadAuthors() async {
           guard let url = URL(string: "\(API.baseURL)/authors/") else { return }
            var request = URLRequest(url: url)
                request.httpMethod = "GET"
           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               let decoded = try JSONDecoder().decode([AuthorAPIModel].self, from: data)
               authors = decoded
           } catch {
               print("Ошибка загрузки авторов: \(error)")
           }
       }

    
    @ViewBuilder
    private func artworkCard(for artwork: ArtworkAPIModel) -> some View {
        NavigationLink {
            ArtworkDetailView(artworkID: artwork.id)
        } label: {
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: "\(API.baseURL)/\(artwork.image)")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 209, height: 328)
                .clipped()
                .cornerRadius(12)

                VStack(spacing: 2) {
                    Text(artwork.title)
                        .font(.custom("EB Garamond", size: 20))
                        .bold()
                        .tracking(1)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(artwork.author?.name ?? "Неизвестный автор")
                        .font(.custom("EB Garamond", size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(6)
                .background(Color.white.opacity(0.85))
                .cornerRadius(8)
                .padding(8)
            }
        }
        .frame(width: 209, height: 328)
        .padding(.leading, artwork.id == artworks.first?.id ? 15 : 0)
        .padding(.trailing, artwork.id == artworks.last?.id ? 16 : 0)
        .buttonStyle(.plain)
    }
}

