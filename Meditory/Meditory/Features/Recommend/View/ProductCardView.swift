import SwiftUI

/// 단일 상품을 카드 형태로 표시하는 뷰
struct ProductCardView: View {
  /// 표시할 상품 데이터
  let product: Product

  var body: some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      // 상품 이미지
      Image(product.imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .cornerRadius(.smallRadius)

      // 브랜드명
      Text(product.brand)
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
        .foregroundColor(.gray)

      // 상품명 (최대 2줄까지 표시)
      Text(product.name)
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
        .lineLimit(2)

      // 별 아이콘 (추후 평점 표시 확장 가능)
      HStack(spacing: .smallSpacing) {
        Image(systemName: "star.fill")
          .foregroundColor(.yellow)
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
      }
    }
    .frame(width: 120)
    .padding(.smallSpacing)
    .background(Color(.systemGray6))
    .cornerRadius(.smallRadius)
  }
}

