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

      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: .smallSpacing) {
            Color.clear
              .frame(width: 1, height: 1)
              .id("HEAD")

            if products.isEmpty {
              ForEach(0..<6, id: \.self) { _ in
                VStack(alignment: .leading, spacing: .smallSpacing) {
                  ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(10))
                    .frame(width: 110, height: 110)
                  ShimmerView(widthRatio: 0.55, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 12)
                  ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 12)
                  ShimmerView(widthRatio: 0.8, cornerRadius: .fixed(6))
                    .frame(width: 110, height: 12)
                }
              }
            } else {
              ForEach(products) { product in
                NavigationLink {
                  if let link = product.link, let url = URL(string: link) {
                    WebPage(url: url, title: product.name)
                  }
                } label: {
                  ProductTile(product: product)
                }
                .buttonStyle(PlainButtonStyle())
              }
            }
          }
        }
        // 카테고리 바뀌면 맨 앞으로 스크롤
        .onChange(of: selectedCategory) { _, _ in
          withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo("HEAD", anchor: .leading)
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
