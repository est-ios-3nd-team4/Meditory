import SwiftUI
import SwiftData

struct RecommendView: View {
  @State private var isOverlappingHeader = false
  // 헤더의 global maxY
  @State private var headerBottomY: CGFloat = 0
  // 첫 카드의 global minY
  @State private var firstCardTopY: CGFloat = .infinity

  @State private var searchText = ""

  @State private var selectedScene: SceneTab = .recommend

  @Environment(\.colorScheme) private var colorScheme

  @Environment(\.modelContext) private var context

  @State private var didSeedNutrients = false

  @State private var refreshID = UUID()

  @StateObject private var recommendVM = ProductRecommendViewModel()

  @StateObject private var nutrientVM = NutrientViewModel()

  @State private var showNutrientDetail = false

  @State private var items: [Product] = []

  private let imageService = GoogleCSEImageClient()

  private func hydrateImagesForCurrentItems() {
    let current = items
    Task {
      // id -> url 매핑으로 받아오기
      var results: [UUID: ImageResult] = [:]
      var errors: [Error] = []

      try? await withThrowingTaskGroup(of: (UUID, ImageResult?, Error?).self) { group in
        for product in current {
          group.addTask { [imageService] in
            do {
              let result = try await imageService.fetchImageAndLink(for: product.brand, name: product.name)
              return (product.id, result, nil)
            } catch {
              return (product.id, nil, error)
            }
          }
        }
        for try await (id, result, err) in group {
          if let result {
            results[id] = result
          }

          if let err { errors.append(err) }
        }
      }

      await MainActor.run {
        // 기존 brand/name/id는 유지하고 image만 채움
        self.items = current.map { product in
          let imageResult = results[product.id]
          let imageName = imageResult?.imageURL ?? ""
          return Product(
            id: product.id,
            imageName: imageName,
            brand: product.brand,
            name: product.name,
            link: imageResult?.productLink
          )
        }
      }
    }
  }

  enum SceneTab {
    case recommend
    case scrap
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        ZStack {
          VStack(alignment: .leading) {
            ZStack(alignment: .trailing) {
              // 검색창
              NavigationLink(destination: SearchView()) {
                HStack {
                  Text(searchText.isEmpty ? "영양성분 또는 영양제를 검색해보세요!" : searchText)
                    .foregroundColor(searchText.isEmpty ? .gray : .black)
                    .font(.notoSans(weight: .medium, size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)

                  Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(.defaultRadius)
                .padding(16)
                .modifier(UnifiedShadow())
              }
              .buttonStyle(PlainButtonStyle())
            }

            // 추천 / 스크랩
            HStack {
              Button {
                selectedScene = .recommend
              } label: {
                VStack {
                  Text("추천")
                    .foregroundColor(selectedScene == .recommend ? .white : Color.white.opacity(0.5))
                    .font(.notoSans(weight: .bold, size: 16))
                }
              }
              .padding(.trailing, 16)

              Button {
                selectedScene = .scrap
              } label: {
                VStack {
                  Text("스크랩")
                    .foregroundColor(selectedScene == .scrap ? .white : Color.white.opacity(0.5))
                    .font(.notoSans(weight: .bold, size: 16))
                }
              }
            }
            .padding(.horizontal, 32)
          }
          .background(
            GeometryReader { proxy in
              let headerBottom = proxy.frame(in: .global).maxY
              Color.clear
                .onAppear { headerBottomY = headerBottom }
                .onChange(of: headerBottom) { _, new in
                  headerBottomY = new
                }
            }
          )
        }
        .allowsHitTesting(!(isOverlappingHeader && selectedScene == .recommend))
        .zIndex(0)

        GeometryReader { geo in
          ScrollView(.vertical, showsIndicators: false) {
            ZStack {
              RoundedRectangle(cornerRadius: .defaultRadius)
                .fill(colorScheme == .dark ? Color.black : Color.customBackground)
              //.modifier(UnifiedShadow())
                .frame(minHeight: geo.size.height)

              if selectedScene == .recommend {
                recommendContent
              }
              else if selectedScene == .scrap {
                scrapContent
              }
            }
          }
          .onChange(of: headerBottomY) {
            isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
          }
          .onChange(of: firstCardTopY) {
            isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
          }
          .scrollClipDisabled(true)
          .zIndex(1)
        }
      }
      .background(backgroundView)

    }
    .onAppear(perform: onAppear)

    .onChange(of: nutrientVM.recommend) {
      guard !nutrientVM.recommend.isEmpty else { return }
      nutrientVM.saveRecommendations(to: context)
    }
    .navigationDestination(isPresented: $showNutrientDetail) {
      RecommendNutrientsView(nutrients: nutrientVM.recommend)
    }
  }

  private var recommendContent: some View {
    VStack(spacing: 24) {
      Color.clear
        .frame(height: 1)
        .background(
          GeometryReader { proxy in
            let cardTop = proxy.frame(in: .global).minY
            Color.clear
              .onAppear { firstCardTopY = cardTop }
              .onChange(of: cardTop) { _, new in
                firstCardTopY = new
              }
          }
        )
      ImageCardView(
        title: "@@님 맞춤 추천",
        categories: ["장 건강", "혈관 & 혈액순환"],
        desc: "* 본결과는 의사의 처방을 대신하지 않습니다.",
        products: items,
        onCategoryTap: { category in
          Task {
            await recommendVM.loadProducts(for: category)
            items = recommendVM.products
          }
        }
      )
      .font(.notoSans(weight: .medium, size: 15))
      .modifier(UnifiedShadow())
      .padding(.horizontal, 16)

      NutrientCardView(
        nutrients: nutrientVM.chip,
        onSeeDetail: { showNutrientDetail = true }
      )
      .id(nutrientVM.chip.joined(separator: "|"))
      .padding(.horizontal, 16)
      .modifier(UnifiedShadow())

      ScoreView()
        .padding(.horizontal, 16)
        .modifier(UnifiedShadow())
        .padding(.bottom, .defaultSpacing)
    }
  }

  private var scrapContent: some View {
    VStack {
      ScrapView()
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
  }

  private var backgroundView: some View {
    GeometryReader { geo in
      let topH = geo.size.height * 0.5 + geo.safeAreaInsets.top
      VStack(spacing: 0) {
        (colorScheme == .dark ? Color.black : Color.main)
          .frame(height: topH)
          .ignoresSafeArea(edges: .top)

        (colorScheme == .dark ? Color.black : Color.customBackground)
          .ignoresSafeArea()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
  }

  private func onAppear() {
    guard !didSeedNutrients else { return }
    didSeedNutrients = true

#if DEBUG
    print("apiKey len:", GoogleKey.apiKey.count, "cx:", GoogleKey.cx)
#endif

    if nutrientVM.chip.isEmpty {
      nutrientVM.load(userName: "@@")
    }
  }


  private func updateOverlapState() {
    isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
  }
}


#Preview {
  RecommendView()
}
