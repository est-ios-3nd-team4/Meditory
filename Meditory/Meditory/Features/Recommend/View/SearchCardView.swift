import SwiftUI

struct SearchCardView: View {
  let imageURL: String
  let brand: String
  let productName: String
  let link: String?
  let onOpen: (URL) -> Void

  let imgSize: CGFloat = 100

  @Environment(\.openURL) private var openURL
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: .defaultSpacing) {
      AsyncImage(url: URL(string: imageURL)) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .frame(width: imgSize, height: imgSize)
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
            .frame(width: imgSize, height: imgSize)
            .cornerRadius(.smallRadius)
        case .failure:
          Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: imgSize, height: imgSize)
            .foregroundColor(.gray)
        @unknown default:
          EmptyView()
        }
      }

      VStack(alignment: .leading) {
        Text(brand)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
          .foregroundColor(.secondary)

        Text(productName)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 2))
          .lineLimit(2)
      }

      Spacer()

      if let link = link, let url = URL(string: link) {
        Button {
          onOpen(url)
        } label: {
          Image(systemName: "chevron.right")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
            .padding(16)
            .contentShape(Rectangle())
        }
      }
    }
    .padding(.vertical, .smallSpacing)
    .padding(.horizontal, .defaultSpacing)
    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
    .cornerRadius(.defaultRadius)
  }
}

//#Preview {
//  SearchCardView(
//    imageURL: "https://pillyze.com/images/sample.jpg",
//    brand: "세라엑스",
//    productName: "혈당콜레스테롤 프로케어",
//    link: "https://pillyze.com/product/123", onOpen: <#(URL) -> Void#>
//  )
//}
