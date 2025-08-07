import SwiftUI

struct Product: Identifiable {
  let id = UUID()
  let imageName: String
  let brand: String
  let name: String
}

struct CardView: View {
  var title: String
  var categories: [String]
  var desciption: String
  let products: [Product]

  @State private var selectedCategory: String?

  @Environment(\.colorScheme) private var colorScheme

  init(title: String, categories: [String], desciption: String, products: [Product]) {
    self.title = title
    self.categories = categories
    self.desciption = desciption
    self.products = products
    _selectedCategory = State(initialValue: categories.first)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text(title)
          .font(.notoSans(weight: .medium, size: 18))

        Spacer()

        Button {

        } label: {
          Text("수정하기")
            .font(.notoSans(weight: .medium, size: 12))

        }
      }

      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          ForEach(categories, id: \.self) { category in
            Button {
              selectedCategory = category
            } label: {
              Text(category)
                .foregroundColor(
                  selectedCategory == category ?
                  (colorScheme == .dark ? Color.white : Color.main)
                  : (colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                  selectedCategory == category ?
                  (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3)) : Color.clear)
                .overlay {
                  RoundedRectangle(cornerRadius: 20)
                    .stroke(
                      selectedCategory == category
                      ? (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3))
                      : Color.gray,
                      lineWidth: 1
                    )
                }
                .cornerRadius(20)

            }
          }
        }
      }

      ZStack {
        RoundedRectangle(cornerRadius: 14)
          .fill(Color(.systemGray5))
          .frame(height: 40)


        Text(desciption)
          .font(.notoSans(weight: .medium, size: 12))
          .foregroundColor(.gray)
      }

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 8) {
          ForEach(products) { product in
            VStack(alignment: .leading, spacing: 8) {
              Image(product.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(12)

              Text(product.brand)
                .font(.notoSans(weight: .medium, size: 15))
                .foregroundColor(.gray)
                .frame(width: 90, alignment: .leading)

              Text(product.name)
                .font(.notoSans(weight: .medium, size: 15))
                .frame(width: 90, height: 50, alignment: .leading)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            }
            .frame(width: 100)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

    }
    .padding()
    .background(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
    .cornerRadius(20)

  }
}

//#Preview {
//    CardView()
//}
