import SwiftUI

// 이미지 캐싱해보기
struct Product: Identifiable, Codable {
  var id = UUID()
  var imageName: String = ""
  var brand: String
  var name: String
  var link: String?

  enum CodingKeys: String, CodingKey {
      case brand, name
    }

  init(id: UUID = UUID(), imageName: String = "", brand: String, name: String, link: String? = nil) {
    self.id = id
    self.imageName = imageName
    self.brand = brand
    self.name = name
    self.link = link
  }
}

struct ImageCardView: View {
  let title: String
  let categories: [String]
  let desc: String
  let products: [Product]
  var onCategoryTap: ((String) -> Void)?

  @State private var selectedCategory: String?
  @State private var didTriggerInitialLoad = false

  @Environment(\.colorScheme) private var colorScheme

  init(title: String, categories: [String], desc: String, products: [Product], onCategoryTap: ((String) -> Void)? = nil) {
    self.title = title
    self.categories = categories
    self.desc = desc
    self.products = products
    self.onCategoryTap = onCategoryTap
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
          ForEach(categories, id: \.self) { category in
            Button {
              onCategoryTap?(category)
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
                  RoundedRectangle(cornerRadius: .defaultRadius)
                    .stroke(
                      selectedCategory == category
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
          ForEach(products) { product in
            NavigationLink {
              if let link = product.link,
                 let url = URL(string: link) {
                WebView(url: url)
                  .navigationTitle(product.name)
              }
            } label: {
              VStack(alignment: .leading, spacing: .smallSpacing) {
                if let imageURL = URL(string: product.imageName), !product.imageName.isEmpty {
                  AsyncImage(url: URL(string: product.imageName)) { phase in
                    switch phase {
                    case .success(let img):
                      img.resizable().scaledToFill()
                    case .failure:
                      Color.gray.opacity(0.2)
                    default:
                      Color.gray.opacity(0.1)
                    }
                  }
                  .frame(width: 110, height: 110, alignment: .center)
                  .clipShape(RoundedRectangle(cornerRadius: .smallRadius))
                } else {
                  Color.gray
                    .frame(width: 110, height: 110, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: .smallRadius))
                }

                Text(product.brand)
                  .padding(.leading, 2)
                  .font(.notoSans(weight: .medium, size: 13))
                  .foregroundStyle(.gray)
                  .frame(width: 110, height: 16, alignment: .topLeading)

                Text(product.name)
                  .padding(.leading, 2)
                  .font(.notoSans(weight: .medium, size: 12))
                  .lineLimit(2)
                  .multilineTextAlignment(.leading) 
                  .frame(width: 110, height: 40, alignment: .topLeading)
              }
            }
            .buttonStyle(PlainButtonStyle())
          }
        }
      }
    }
    .padding()
    .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
    .cornerRadius(.defaultRadius)
    .onAppear {
      if let initial = selectedCategory {
        guard !didTriggerInitialLoad else { return }
        didTriggerInitialLoad = true
        if let initial = selectedCategory {
          onCategoryTap?(initial)
        }
      }
    }
  }
}



//#Preview {
//    ImageCardView()
//}
