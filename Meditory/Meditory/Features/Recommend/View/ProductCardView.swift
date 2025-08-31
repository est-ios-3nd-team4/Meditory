import SwiftUI

struct ProductCardView: View {
  let product: Product

  var body: some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      Image(product.imageName)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .cornerRadius(.smallRadius)

      Text(product.brand)
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
        .foregroundColor(.gray)

      Text(product.name)
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
        .lineLimit(2)

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

