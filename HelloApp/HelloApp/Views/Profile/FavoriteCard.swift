import SwiftUI

struct FavoriteCard: View {
    let art: ArtworkAPIModel

    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: "\(API.baseURL)/\(art.image)")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 153, height: 153)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(spacing: 2) {
                Text(art.title)
                    .font(.custom("EB Garamond", size: 18))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .foregroundColor(.black)

                Text(art.author?.name ?? "Неизвестный автор")
                    .font(.custom("EB Garamond", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
