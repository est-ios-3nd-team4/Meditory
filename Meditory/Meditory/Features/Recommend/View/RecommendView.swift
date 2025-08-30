import SwiftUI
import SwiftData
import Foundation

struct RecommendView: View {

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  @Query private var users: [User]

  @Query(sort: [SortDescriptor(\Meal.date, order: .reverse)])
  private var meals: [Meal]

  @StateObject private var recommendVM = ProductRecommendViewModel()
  @StateObject private var nutrientVM = NutrientViewModel()

  private let mealWindowDays: Int = 30
  private var recentMeals: [Meal] {
    guard let start = Calendar.current.date(byAdding: .day, value: -mealWindowDays, to: Date()) else { return meals }
    return meals.filter { $0.date >= start }
  }

  private var nutrientReloadKey: String {
    let who = userNameKey
    let count = recentMeals.count
    let latestTS = recentMeals.first?.date.timeIntervalSince1970 ?? 0
    return "\(who)|\(count)|\(Int(latestTS))"
  }

  private var dietInputForScore: DietInput {
    // Meal → Food 이름으로 단순 변환 (중복 제거/공백 제거)
    let names = recentMeals.flatMap { $0.foods.map { $0.foodName.trimmingCharacters(in: .whitespacesAndNewlines) } }
    let unique = Array(Set(names)).filter { !$0.isEmpty }
    return DietInput(foods: unique, patterns: nil) // 패턴 수집 시 여기 채워넣기
  }

  @State private var lastLoadedName: String = ""
  @State private var isOverlappingHeader = false
  @State private var headerBottomY: CGFloat = 0
  @State private var firstCardTopY: CGFloat = .infinity
  @State private var searchText = ""
  @State private var selectedScene: SceneTab = .recommend
  @State private var didSeedNutrients = false
  @State private var refreshID = UUID()
  @State private var showNutrientDetail = false
  @State private var items: [Product] = []
  @State private var latestScore: Int? = nil
  @State private var isLoadingReal = false
  @State private var hasRealData = false
  @State private var dummyChipSignature = ""
  @State private var dummyRecommendSignature = ""
  @State private var hasRealNutrientData = false
  @State private var categoryTask: Task<Void, Never>?
  @State private var hydrateTask: Task<Void, Never>?
  @State private var isLoadingProducts = false

  private func chipSignature(_ chips: [String]) -> String {
    chips.sorted().joined(separator: "|")
  }
  private func recommendSignature(_ nutrients: [Nutrient]) -> String {
    nutrients.map { $0.id }.sorted().joined(separator: "|")
  }

  private var imageService = GoogleCSEImageClient()

  private var userConcerns: [String] {
    guard let concerns = users.first?.userExtraInfos.first?.concern else { return [] }
    return concerns.map { $0.value }
  }

  private func hydrateImagesForCurrentItems() {
    guard hasRealData else { return }

    hydrateTask?.cancel()

    let current = items
    hydrateTask = Task {
      var results: [UUID: ImageResult] = [:]
      var errors: [Error] = []

      try? await withThrowingTaskGroup(of: (UUID, ImageResult?, Error?).self) { group in
        for product in current {
          if Task.isCancelled {
            group.cancelAll()
            return
          }
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
          if Task.isCancelled {
            group.cancelAll()
            return
          }
          if let result {
            results[id] = result
          }

          if let err { errors.append(err) }
        }
      }
      guard !Task.isCancelled else { return }

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

  private var name: String {
    let rawName = users.first?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    return rawName.isEmpty ? "사용자" : rawName
  }

  private var userNameKey: String {
    users.first?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
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
                    .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
                    .frame(maxWidth: .infinity, alignment: .leading)

                  Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                }
                .padding(.vertical, .smallSpacing)
                .padding(.horizontal, .defaultSpacing)
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
                    .font(.notoSans(weight: .bold, size: .defaultFontSize - 2))
                }
              }
              .padding(.trailing, .defaultSpacing)

              Button {
                selectedScene = .scrap
              } label: {
                VStack {
                  Text("스크랩")
                    .foregroundColor(selectedScene == .scrap ? .white : Color.white.opacity(0.5))
                    .font(.notoSans(weight: .bold, size: .defaultFontSize - 2))
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
            ZStack(alignment: .topLeading) {
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
          .onChange(of: headerBottomY, initial: false) { _, new in
            isOverlappingHeader = firstCardTopY < (new - 2)
          }
          .onChange(of: firstCardTopY, initial: false) { _, new in
            isOverlappingHeader = new < (headerBottomY - 2)
          }
          .task(id: nutrientReloadKey) {
            guard users.first != nil else { return }
            nutrientVM.load(user: users.first, meals: recentMeals)
          }
          .scrollClipDisabled(true)
          .zIndex(1)
        }
      }
      .background(backgroundView)

    }
    .onAppear(perform: onAppear)
    .onDisappear {
      categoryTask?.cancel()
      hydrateTask?.cancel()
    }

    .onChange(of: nutrientVM.recommendations) {
      guard !nutrientVM.recommendations.isEmpty else { return }
      let currentSig = recommendSignature(nutrientVM.recommendations)
      guard currentSig != dummyRecommendSignature else { return }

      hasRealNutrientData = true
      nutrientVM.saveRecommendations(to: context)
    }


    .onChange(of: nutrientVM.chips) {
      guard !nutrientVM.chips.isEmpty else { return }
      let currentSig = chipSignature(nutrientVM.chips)
      if currentSig != dummyChipSignature {
        hasRealNutrientData = true
      }
    }
  }

  private var recommendContent: some View {
    VStack(spacing: 16) {
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
        title: "\(name) 님 맞춤 추천",
        categories: userConcerns,
        desc: "* 본결과는 의사의 처방을 대신하지 않습니다.",
        products: items,
        isLoading: isLoadingProducts,
        onCategoryTap: { category in
          categoryTask?.cancel()
          Task { @MainActor in
            isLoadingProducts = true
            items = []
          }
          categoryTask = Task {
            defer { categoryTask = nil }
            await recommendVM.loadProducts(for: category)
            guard !Task.isCancelled else { return }
            let real = recommendVM.products
            await MainActor.run {
              items = real
              hasRealData = !real.isEmpty
              isLoadingProducts = false
            }
          }
        }
      )
      .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
      .modifier(UnifiedShadow())
      .padding(.horizontal, 16)

      NutrientCardView(
        nutrients: nutrientVM.chips,
        onSeeDetail: { showNutrientDetail = true },
        isLoading: !hasRealNutrientData,
        userName: name
      )
      .id(chipSignature(nutrientVM.chips))
      .padding(.horizontal, 16)
      .padding(.top, .smallSpacing)
      .modifier(UnifiedShadow())
      .navigationDestination(isPresented: $showNutrientDetail) {
        RecommendNutrientsView(nutrients: nutrientVM.recommendations, userName: name)
      }

      ScoreView(
        user: users.first,
        meals: recentMeals,
        diet: dietInputForScore,
        windowDays: mealWindowDays,
        onResultUpdate: { result in
          latestScore = result.score
        }
      )
      .padding(.horizontal, 16)
      .padding(.top, .smallSpacing)
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
          Color.main
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

    seedDummyNutrientsIfNeeded()

#if DEBUG
    print("apiKey len:", GoogleKey.apiKey.count, "cx:", GoogleKey.cx)
#endif
    hasRealNutrientData = false

    nutrientVM.load(user: users.first, meals: recentMeals)

    fetchRealDataOnLaunch()
  }

  private func fetchRealDataOnLaunch() {
    guard !isLoadingReal else { return }
    isLoadingReal = true

    Task {
      defer {
        isLoadingReal = false
      }

      nutrientVM.load(user: users.first, meals: recentMeals)

      await recommendVM.loadProducts(for: "장 건강")
      let real = recommendVM.products

      await MainActor.run {
        if !real.isEmpty {
          items = real
          hasRealData = true
        }
      }
    }
  }

  private func updateOverlapState() {
    isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
  }

  // 더미데이터(영양성분)
  private func seedDummyData() {
    items = [
      Product(
        id: UUID(),
        imageName: "https://iherb-res.cloudinary.com/image/upload/f_auto,q_auto:eco/images/drb/drb00396/l/93.jpg",
        brand: "Doctor's Best",
        name: "코엔자임 Q10",
        link: "https://kr.iherb.com/pr/doctor-s-best-high-absorption-coq10-100-mg-120-veggie-capsules/16657"),

      Product(
        id: UUID(),
        imageName: "https://iherb-res.cloudinary.com/image/upload/f_auto,q_auto:eco/images/nrs/nrs01020/l/12.jpg",
        brand: "Nordic Naturals",
        name: "얼티메이트 오메가",
        link: "https://kr.iherb.com/pr/nordic-naturals-ultimate-omega-1280-mg-60-soft-gels/4216"),

      Product(
        id: UUID(),
        imageName: "https://iherb-res.cloudinary.com/image/upload/f_auto,q_auto:eco/images/cgn/cgn01355/l/26.jpg",
        brand: "California Gold Nutrition",
        name: "LactoBif 프로바이오틱스",
        link: "https://kr.iherb.com/pr/california-gold-nutrition-lactobif-probiotics-30-billion-cfu-60-veggie-capsules/64098")
    ]

    let nutrients = makeDummyNutrients()
    let dummyChips = ["프로바이오틱스", "오메가3", "마그네슘"]

    dummyRecommendSignature = recommendSignature(nutrients)
    dummyChipSignature = chipSignature(dummyChips)

    nutrientVM.recommendations = nutrients
    if nutrientVM.chips.isEmpty {
      nutrientVM.chips = dummyChips
    }
    hasRealNutrientData = false
  }

  private func seedDummyNutrientsIfNeeded() {
    let nutrients = makeDummyNutrients()
    let dummyChips = ["프로바이오틱스", "오메가3", "마그네슘"]

    dummyRecommendSignature = recommendSignature(nutrients)
    dummyChipSignature = chipSignature(dummyChips)

    nutrientVM.recommendations = nutrients
    if nutrientVM.chips.isEmpty {
      nutrientVM.chips = dummyChips
    }
    hasRealNutrientData = false
  }

  // 더미데이터 (이미지카드)
  private func dummyProducts(for category: String) -> [Product] {
    switch category {
    case "장 건강":
      return [
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/591/160/img/6160591_1.jpg?_v=20220804162302",
          brand: "종근당건강",
          name: "락토핏 생유산균 코어",
          link: "https://prod.danawa.com/info/?pcode=6160591"
        ),
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/981/905/img/5905981_1.jpg?_v=20230719101427",
          brand: "일동제약",
          name: "지큐랩 데일리 유산균",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fprod.danawa.com%2Finfo%2F%3Fpcode%3D5905981&psig=AOvVaw3m8RAJnZH0_LfJruoR9Na8&ust=1755679580645000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCODRo6m-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/158/923/img/4923158_1.jpg?_v=20191111162632",
          brand: "GC녹십자웰빙",
          name: "프로바이오틱스 유산균 19",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fprod.danawa.com%2Finfo%2F%3Fpcode%3D4923158&psig=AOvVaw0rEvTLFwKcFWnBexQvBGx2&ust=1755679632626000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCKjA8bi-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://ecimg.cafe24img.com/pg715b64657646058/memory7942/web/product/big/20250619/db810da6baa0ded0eb297c110bde1e2d.jpg",
          brand: "광동제약",
          name: "마이프로바이오틱스",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fkdmemory365.com%2Fproduct%2F%25EA%25B4%2591%25EB%258F%2599-%25EB%25A9%2594%25EB%25AA%25A8%25EB%25A6%25AC365-%25ED%2598%2588%25EB%258B%25B9%25EC%259C%25A0%25EC%2582%25B0%25EA%25B7%25A0%2F20%2F%3Fsrsltid%3DAfmBOoqZqIs2_NVOVdMZzQ8IpSbO6Pn9uSz9Nkrb--WucRMem6FRpd3X&psig=AOvVaw164zkJuV5JHaGtJZdyK47C&ust=1755679655453000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCMDvlMO-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://image2.lotteimall.com/goods/78/17/35/1856351778_4.jpg/dims/resizemc/550x550/optimize",
          brand: "뉴트리코어",
          name: "프로바이오틱스 프리미엄",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fm.lotteimall.com%2Fgoods%2FviewGoodsDetail.lotte%3Fgoods_no%3D1856351778&psig=AOvVaw0NyDC0lGD1eH4MziXPtkf2&ust=1755679688628000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJD0u9O-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/391/567/img/13567391_3.jpg?_v=20230830135335",
          brand: "노르딕내추럴스",
          name: "얼티메이트 오메가",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fprod.danawa.com%2Finfo%2F%3Fpcode%3D13567391&psig=AOvVaw3ajfwNC2UbjB-QtXJMayHp&ust=1755679711610000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJiwlN6-lo8DFQAAAAAdAAAAABAE"
        )
      ]

    case "혈관 & 혈액순환":
      return [
        Product(
          id: UUID(),
          imageName: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSKbYJNTMg6bjCYWD9ih_3Nl_IyTPLYIBlARA&s",
          brand: "닥터스베스트",
          name: "코엔자임 Q10",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.ople.com%2Fm%2Fshop%2Fitem.php%3Fit_id%3D1504270838&psig=AOvVaw2j8XrncsfCeo3L0T-roC-N&ust=1755679739802000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCLjFmuu-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://thumbnail10.coupangcdn.com/thumbnails/remote/492x492ex/image/vendor_inventory/22b8/410213a7647c3a53e28e74db3f1c6fbe9a810f382d6d54028cb15c3fec45.jpg",
          brand: "GNC",
          name: "트리플 스트렝스 피쉬오일",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.coupang.com%2Fvp%2Fproducts%2F7940413771%3FitemId%3D21868825008%26vendorItemId%3D88916993149&psig=AOvVaw1IC7_IdJERtKDDtWviOYWm&ust=1755679769328000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJj5-Pq-lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/159/171/img/29171159_1.jpg?_v=20231024115233&shrink=360:360",
          brand: "네이처메이드",
          name: "피쉬오일 오메가3",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fprod.danawa.com%2Finfo%2F%3Fpcode%3D29171159&psig=AOvVaw1Xam5zaPyLeSJ1wU9MSojA&ust=1755679795407000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCICb-YW_lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://img.danawa.com/prod_img/500000/937/674/img/3674937_1.jpg?_v=20231012102707",
          brand: "솔가",
          name: "오메가3 700",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fprod.danawa.com%2Finfo%2F%3Fpcode%3D3674937&psig=AOvVaw0KyspXnCeAMUbyErBBWEfi&ust=1755679813950000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCPCbl4-_lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://thumbnail6.coupangcdn.com/thumbnails/remote/492x492ex/image/retail/images/7c8037c1-214e-4b51-8037-6ca7b91feae73887643485606645677.png",
          brand: "바이오가이아",
          name: "프로텍티스 유산균 드롭",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.coupang.com%2Fvp%2Fproducts%2F6758879578&psig=AOvVaw0kuJL_2KOTBZkz4yDFwzmo&ust=1755679838743000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOi0sMW_lo8DFQAAAAAdAAAAABAE"
        ),
        Product(
          id: UUID(),
          imageName: "https://media.amway.co.kr/sys-master/images/hdf/hcf/9298168217630/NU_120342K_640_1_R.jpg",
          brand: "뉴트리라이트",
          name: "오메가-3 컴플렉스",
          link: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.amway.co.kr%2Fshop%2Fnutrition%2Ffunctional%2Fp%2F120342K&psig=AOvVaw3JtRB_U13pgrTUU1Zx5kPX&ust=1755679988744000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCJC3w-K_lo8DFQAAAAAdAAAAABAE"
        )
      ]

    default:
      return items
    }
  }

  // 더미데이터(영양성분 상세보기)
  private func makeDummyNutrients() -> [Nutrient] {
    return [
      Nutrient(
        id: UUID().uuidString,
        name: "프로바이오틱스",
        hashtags: ["장건강", "면역", "마이크로바이옴"],
        description: "",
        title: "프로바이오틱스가 왜 필요할까요?",
        content: """
        프로바이오틱스는 우리 몸속에서 유익균과 유해균의 균형을 맞추어 장 건강을 돕는 살아있는 유산균이에요. 
        규칙적으로 섭취하면 변비, 설사 같은 소화 문제를 완화하는 데 도움을 줄 수 있고, 장내 환경을 개선하여 면역 기능 강화에도 긍정적인 영향을 줍니다.
        """,
        positiveKeywords: [],
        negativeKeywords: []
      ),
      Nutrient(
        id: UUID().uuidString,
        name: "오메가3",
        hashtags: ["혈중중성지방", "혈관건강", "EPA/DHA"],
        description: "",
        title: "오메가3 효능 요약",
        content: """
        오메가3 지방산은 대표적으로 EPA와 DHA가 있으며, 심혈관 건강에 매우 중요한 영양소예요. 
        혈중 중성지방 수치를 낮추고 혈액순환을 개선하는 데 도움을 주어 뇌혈관 질환이나 심장질환 위험을 줄일 수 있습니다. 
        
        또한 뇌세포막을 구성하는 중요한 성분이라 기억력과 집중력 향상에도 긍정적인 역할을 합니다.
        """,
        positiveKeywords: [],
        negativeKeywords: []
      ),
      Nutrient(
        id: UUID().uuidString,
        name: "마그네슘",
        hashtags: ["근육이완", "수면", "신경안정"],
        description: "",
        title: "마그네슘, 언제 먹을까?",
        content: """
        마그네슘은 300가지 이상의 효소 반응에 관여하는 필수 미네랄로, 특히 근육과 신경 안정에 중요한 역할을 해요. 
        부족하면 눈떨림, 근육 경련, 피로감, 불면 같은 증상이 나타날 수 있습니다. 
        """,
        positiveKeywords: [],
        negativeKeywords: []
      )
    ]
  }

}


#Preview {
  RecommendView()
}
