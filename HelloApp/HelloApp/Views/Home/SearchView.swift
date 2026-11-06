import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var artworks: [ArtworkAPIModel] = []
    @State private var filtered: [ArtworkAPIModel] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Поиск")
                    .font(.custom("EB Garamond", size: 29))
                    .fontWeight(.semibold)
                    .padding(.top, 15)

                HStack {
                    TextField("Введите название картины или имя автора...", text: $searchText)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: searchText) { _ in
                                filterArtworks()
                            }

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
                .padding(.horizontal)
            }

            ScrollView {
                LazyVStack(spacing: 13) {
                    ForEach(filtered) { art in
                        ArtworkSearchRow(art: art)
                    }
                }
                .padding(.vertical)
            }
        }
        .task {
            await loadArtworks()
        }
    //    print("task started") // только для отладки
            // await loadArtworks() // пока отключаем
       // .navigationBarBackButtonHidden(true)
    }

    private func loadArtworks() async {
        guard let url = URL(string: "\(API.baseURL)/artworks") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ArtworkAPIModel].self, from: data)
            artworks = decoded
            filtered = decoded
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }

    private func filterArtworks() {
        if searchText.isEmpty {
            filtered = artworks
        } else {
            filtered = artworks.filter { art in
                art.title.localizedCaseInsensitiveContains(searchText)
                
            }
        }
    }
}

private struct ArtworkSearchRow: View {
    let art: ArtworkAPIModel

    var body: some View {
        NavigationLink {
            ArtworkDetailView(artworkID: art.id)
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: "\(API.baseURL)/\(art.image)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Color.red // при ошибке
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 110, height: 110)
                .cornerRadius(5)

                VStack(alignment: .leading, spacing: 4) {
                    Text(art.title)
                        .font(.custom("EB Garamond", size: 22))
                        .fontWeight(.semibold)
                    Text(art.author?.name ?? "Неизвестный автор")
                        .font(.custom("EB Garamond", size: 17))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

