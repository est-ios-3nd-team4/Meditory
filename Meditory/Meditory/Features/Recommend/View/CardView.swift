import SwiftUI

struct Product: Identifiable {
  let id = UUID()
  var imageName: String
  let brand: String
  let name: String

  init(imageName: String, brand: String, name: String) {
    self.imageName = imageName
    self.brand = brand
    self.name = name
  }
}

struct CardView: View {
  let title: String
  let categories: [String]
  let desc: String
  let products: [Product]
  var onCategoryTap: ((String) -> Void)? = nil

  @State private var selectedCategory: String?
  @Environment(\.colorScheme) private var colorScheme

  init(title: String, categories: [String], desc: String, products: [Product]) {
    self.title = title
    self.categories = categories
    self.desc = desc
    self.products = products
    _selectedCategory = State(initialValue: categories.first)
  }


  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
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
          ForEach(categories, id: \.self) { c in
            Button {
              onCategoryTap?(c)
              selectedCategory = c
            } label: {
              Text(c)
                .foregroundColor(
                  selectedCategory == c ?
                  (colorScheme == .dark ? Color.white : Color.main)
                  : (colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
                )
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                  selectedCategory == c ?
                  (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3)) : Color.clear)
                .overlay {
                  RoundedRectangle(cornerRadius: .defaultRadius)
                    .stroke(
                      selectedCategory == c
                      ? (colorScheme == .dark ? Color.main : Color.sub.opacity(0.3))
                      : Color.gray,
                      lineWidth: 1
                    )
                }
                .cornerRadius(.defaultRadius)
            }
          }
        }.padding(.vertical, 4)
      }

      Text(desc)
        .font(.notoSans(weight: .medium, size: 12))
        .foregroundColor(.gray)


      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: .smallSpacing) {
          ForEach(products) { p in
            VStack(alignment: .leading, spacing: 8) {
              AsyncImage(url: URL(string: p.imageName)) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                case .failure: Color.gray.opacity(0.2)
                default: Color.gray.opacity(0.1)
                }
              }
              .frame(width: 120, height: 100, alignment: .center)
              .clipShape(RoundedRectangle(cornerRadius: .smallRadius))

              Text(p.brand)
                .padding(.leading, 2)
                .font(.notoSans(weight: .medium, size: 13))
                .foregroundStyle(.gray)
                .frame(width: 120, height: 16, alignment: .topLeading)

              Text(p.name)
                .padding(.leading, 2)
                .font(.notoSans(weight: .medium, size: 12))
                .lineLimit(2)
                .frame(width: 120, height: 40, alignment: .topLeading)
            }
          }
        }
      }
    }
    .padding()
    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
    .cornerRadius(.defaultRadius)
  }
}



//#Preview {
//    CardView()
//}
