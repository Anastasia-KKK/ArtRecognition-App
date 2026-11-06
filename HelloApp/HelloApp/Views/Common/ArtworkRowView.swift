import SwiftUI

struct ArtworkRowView: View {
    let artwork: ArtworkAPIModel

    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: "\(API.baseURL)/\(artwork.image)")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(height: 210)
            .frame(maxWidth: .infinity)
            .clipped()
            .cornerRadius(12)

            VStack(spacing: 2) {
                Text(artwork.title)
                    .font(.custom("EB Garamond", size: 15))
                    .fontWeight(.bold)
                Text("Неизвестный автор")
                    .font(.custom("EB Garamond", size: 14))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
            .padding(.bottom, 12)
        }
    }
}
