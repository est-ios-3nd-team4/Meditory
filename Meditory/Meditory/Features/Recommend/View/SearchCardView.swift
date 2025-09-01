import SwiftUI

/// 검색 결과의 단일 상품을 카드 형태로 표시하는 뷰
struct SearchCardView: View {
  /// 상품 이미지 URL
  let imageURL: String
  /// 상품 브랜드명
  let brand: String
  /// 상품 이름
  let productName: String
  /// 상품 상세 페이지 링크 (옵션)
  let link: String?
  /// 상세 링크 열기 액션
  let onOpen: (URL) -> Void

  /// 썸네일 이미지 크기
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
            .padding(.defaultSpacing)
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
