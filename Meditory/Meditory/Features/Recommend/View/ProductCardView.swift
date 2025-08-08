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
        .font(.notoSans(weight: .medium, size: 15))
        .foregroundColor(.gray)

      Text(product.name)
        .font(.notoSans(weight: .medium, size: 15))
        .lineLimit(2)

      HStack(spacing: .smallSpacing) {
        Image(systemName: "star.fill")
          .foregroundColor(.yellow)
          .font(.notoSans(weight: .medium, size: 15))
      }
    }
    .frame(width: 120)
    .padding(8)
    .background(Color(.systemGray6))
    .cornerRadius(.smallRadius)
  }
}

//#Preview {
//    ProductCardView(product: Product)
//}
