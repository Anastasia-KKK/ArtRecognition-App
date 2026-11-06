import SwiftUI

struct SearchHistoryItem: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var author: String
    var viewedAt: Date
}

private extension DateFormatter {
    static let ddMMyyyy: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f
    }()
}


struct HistoryRow: View {
    let item: SearchHistoryItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(item.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 117, height: 117)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.custom("EB Garamond", size: 20))
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(item.author)
                    .font(.custom("EB Garamond", size: 15))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Text(DateFormatter.ddMMyyyy.string(from: item.viewedAt))
                .font(.custom("EB Garamond", size: 12))
                .foregroundColor(.gray)
                .fixedSize()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


struct SearchHistoryView: View {
    @State private var items: [SearchHistoryItem] = [
        SearchHistoryItem(imageName: "Volga",          title: "Бурлаки на Волге",     author: "Репин И.Е.",   viewedAt: .init(timeIntervalSince1970: 1_716_739_200)), // 12/05/2024
        SearchHistoryItem(imageName: "Door",title: "У дверей мечети",      author: "Верещагин В.В.", viewedAt: .init(timeIntervalSince1970: 1_716_048_000)), // 04/05/2024
        SearchHistoryItem(imageName: "Polenov",         title: "Христос и грешница",  author: "Поленов В.Д.", viewedAt: .init(timeIntervalSince1970: 1_714_310_400)), // 20/04/2024
        SearchHistoryItem(imageName: "Zaparozhzi",      title: "Запорожцы",           author: "Репин И.Е.",   viewedAt: .init(timeIntervalSince1970: 1_713_619_200))  // 16/04/2024
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        // Если нужен переход на экран картины:
                        // NavigationLink { ArtworkDetailView(artwork: ...) } label: {
                        HistoryRow(item: item)
                        // }

                        Divider()
                            .padding(.leading, 16 + 120 + 14) // чтоб линия начиналась после изображения
                            .opacity(0.5)
                    }
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
                
                // кнопка очистки
                               if !items.isEmpty {
                                   Button {
                                       withAnimation { items.removeAll() }
                                   } label: {
                                       Text("Очистить историю")
                                           .font(.custom("EB Garamond", size: 18))
                                           .foregroundColor(.red)
                                           .padding()
                                           .background(Color(.systemGray6))
                                           .cornerRadius(12)
                                           .padding(.horizontal, 16)
                                           .padding(.top, 5)
                                   }
                               } else {
                                   Text("История пуста")
                                       .font(.custom("EB Garamond", size: 18))
                                       .foregroundColor(.gray)
                                       .padding(.top, 40)
                               }

                               Spacer(minLength: 32)
                           }
                       }
        // если открываешь из ProfileView внутри NavigationStack —
        // стрелка и системный заголовок появятся сами.
        .navigationTitle("") // оставим пустым, чтобы использовать свой крупный заголовок
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("История поиска")
                    .font(.custom("EB Garamond", size: 29))
                    .fontWeight(.semibold)
                    .padding(.top, 16)
            }
        }
            }
        }
    


#Preview {
    NavigationStack { SearchHistoryView() }
}
