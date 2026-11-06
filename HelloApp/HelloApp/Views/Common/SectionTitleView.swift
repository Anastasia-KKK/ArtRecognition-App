import SwiftUI

struct SectionTitleView: View {
    let title: String
    let padding: CGFloat

    var body: some View {
        Text(title)
            .font(.custom("EB Garamond", size: 22))
            .fontWeight(.medium)
            .padding(.horizontal, padding)
    }
}
