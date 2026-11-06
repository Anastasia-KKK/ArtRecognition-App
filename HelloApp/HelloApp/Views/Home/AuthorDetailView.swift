import SwiftUI

struct AuthorDetail: Identifiable {
    let id = UUID()
    let name: String
    let yearBirth: Int
    let yearDeath: Int
    let portrait: String
    let bio: [String]
    let facts: [String]
    let artworks: [ArtworkAPIModel]
}

struct AuthorDetailView: View {
    let author: AuthorDetail
    private let side: CGFloat = 20

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {

                // Фото и имя
                HStack(alignment: .center, spacing: 14) {
                    Image(author.portrait)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(author.name)
                            .font(.custom("EB Garamond", size: 26))
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Text("\(author.yearBirth) г. – \(author.yearDeath) г.")
                            .font(.custom("EB Garamond", size: 14))
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }
                .padding(.horizontal, side)

                // Биография
                SectionTitleView(title: "Краткая биография", padding: side)

                VStack(alignment: .leading, spacing: 9) {
                    ForEach(author.bio, id: \.self) { paragraph in
                        Text(paragraph)
                            .font(.custom("EB Garamond", size: 18))
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, side)

                // Факты
                if !author.facts.isEmpty {
                    SectionTitleView(title: "Интересные факты", padding: side)

                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(author.facts, id: \.self) { fact in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .font(.custom("EB Garamond", size: 20))
                                Text(fact)
                                    .font(.custom("EB Garamond", size: 18))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.horizontal, side)
                }

                // Картины
                SectionTitleView(title: "Картины художника", padding: side)

                VStack(spacing: 12) {
                    ForEach(author.artworks) { artwork in
                        ArtworkRowView(artwork: artwork)
                    }
                }
                .padding(.horizontal, side)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
