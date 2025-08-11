import SwiftUI
import SwiftData

struct RecommendView: View {
  @State private var searchText = ""

  @State private var selectedScene: SceneTab = .recommend

  @Environment(\.colorScheme) private var colorScheme

  @Environment(\.modelContext) private var context

  @State private var didSeedNutrients = false

  @State private var refreshID = UUID()

  @State private var items: [Product] = [
    Product(imageName: "", brand: "스포츠리서치", name: "트리플 스트렝스 오메가3 피쉬오일"),
    Product(imageName: "", brand: "동아제약", name: "써큐란 알파"),
    Product(imageName: "", brand: "정관장", name: "홍삼정 에브리타임 10ml"),
    Product(imageName: "", brand: "종근당건강", name: "락토핏 생유산균 코어맥스"),
    //  Product(imageName: "", brand: "바이오일레븐", name: "드시모네 데일리"),
    // Product(imageName: "", brand: "덴프스", name: "덴마크 유산균이야기"),
    //  Product(imageName: "", brand: "일동제약", name: "지큐랩 장건강 포스트 솔루션"),
    // Product(imageName: "", brand: "자로우포뮬라", name: "자로우도필러스 EPS 100억 유산균")
  ]

  private let imageService = GoogleCSEImageClient()

  private func hydrateImagesForCurrentItems() {
    let current = items
    Task {
      // id -> url 매핑으로 받아오기
      var results: [UUID: String] = [:]

      try? await withThrowingTaskGroup(of: (UUID, String?).self) { group in
        for p in current {
          group.addTask { [imageService] in
            let url = try await imageService.firstImageURL(for: p.brand, name: p.name)
            return (p.id, url)
          }
        }
        for try await (id, url) in group {
          if let u = url, !u.isEmpty { results[id] = u }
        }
      }

      await MainActor.run {
        // 기존 brand/name/id는 유지하고 image만 채움
        self.items = current.map { p in
          let url = results[p.id] ?? p.imageName
          return Product(imageName: url, brand: p.brand, name: p.name)
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
                  Text(searchText.isEmpty ? "영양성분 및 영양제를 검색해보세요!" : searchText)
                    .foregroundColor(searchText.isEmpty ? .gray : .black)
                    .font(.notoSans(weight: .medium, size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(Color.white)
                .cornerRadius(.defaultRadius)
                .padding(16)
                .modifier(UnifiedShadow())
              }
              .buttonStyle(PlainButtonStyle())

              Button {

              } label: {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.gray)
                  .padding(.trailing, 24)
              }
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
        }
        .zIndex(0)


        GeometryReader { geo in
          ScrollView(.vertical, showsIndicators: false) {
            ZStack {
              RoundedRectangle(cornerRadius: .defaultRadius)
                .fill(colorScheme == .dark ? Color.black : Color.white.opacity(0.98))
                .modifier(UnifiedShadow())
                .padding(.bottom, -80)
                .ignoresSafeArea(.container, edges: .bottom)
                .frame(minHeight: geo.size.height)

              if selectedScene == .recommend {
                VStack(spacing: 24) {
                  // 맞춤 추천 셀
                  CardView(
                    title: "@@님 맞춤 추천",
                    categories: ["장 건강", "혈관 & 혈액순환"],
                    desc: "* 본결과는 의사의 처방을 대신하지 않습니다.",
                    products: items
                  )
                  .font(.notoSans(weight: .medium, size: 15))
                  .modifier(UnifiedShadow())
                  .padding(.top, 24)
                  .padding(.horizontal, 16)


                  // 맞춤 영양소 추천 셀
                  NutrientCardView(nutrients: ["아연", "밀크씨슬", "히알루론산"])
                    .padding(.horizontal, 16)
                    .modifier(UnifiedShadow())

                  ScoreView()
                    .padding(.horizontal, 16)
                    .modifier(UnifiedShadow())
                }
              }

              else if selectedScene == .scrap {
                VStack {
                  ScrapView()
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                }
              }
            }
          }
          .scrollClipDisabled(true)
          .zIndex(1)
        }
      }
      .background(colorScheme == .dark ? Color.black : Color.main)

    }
    .onAppear {
      guard !didSeedNutrients else { return }
      didSeedNutrients = true
      hydrateImagesForCurrentItems()

      let existingNutrients = try? context.fetch(FetchDescriptor<Nutrient>())
      existingNutrients?.forEach { context.delete($0) }

      let dummyNutrients = [
        Nutrient(
          id: "zinc",
          name: "아연",
          hashtags: ["정상적인 면역기능에 필요", "정상적인 세포분열에 필요"],
          description: "영양성분 설명",
          title: "아연은 면역에 필요한 미네랄입니다.",
          content: "아연은 정상적인 세포성장, 생식 기능, 면역 등 체내 여러 활동에 필수적인 미량 영양성분으로 우리 몸 여러부위에 약 1.5~2.5g 정도 존재합니다. 아연의 권장 섭취량은 10mg입니다. 식품으로는 굴 6개 (80g)정도의 양이면 1일 권장 섭취량을 충족하며 그 이외에 콩류 또는 붉은 살코기 등에 함유되어 있습니다.",
          positiveKeywords: [],
          negativeKeywords: []
        ),
        Nutrient(
          id: "milkthistle",
          name: "밀크씨슬",
          hashtags: ["간 건강에 도움을 줄 수 있음"],
          description: "영양성분 설명",
          title: "밀크씨슬 추출물은 간 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
          content: "밀크씨슬은 실리마린(silymarin)이라는 활성 성분을 함유하고 있어 간세포를 보호하고 간 기능 개선에 도움을 줄 수 있습니다. 실리마린은 항산화 효과가 뛰어나며, 음주나 스트레스로 인해 손상된 간세포 회복에 도움이 될 수 있습니다. 일반적으로 하루 140mg 정도의 실리마린 섭취가 권장됩니다. 밀크씨슬 보충제나 추출물로 주로 섭취합니다.",
          positiveKeywords: [],
          negativeKeywords: []
        ),
        Nutrient(
          id: "hyaluronic",
          name: "히알루론산",
          hashtags: ["피부 보습에 도움을 줄 수 있음", "관절 건강에 도움을 줄 수 있음"],
          description: "영양성분 설명",
          title: "히알루론산은 피부 보습과 관절 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
          content: "히알루론산은 체내에 존재하는 다당류로, 피부와 관절, 눈 등에 풍부하게 분포되어 있으며 수분을 끌어당기고 유지하는 기능을 합니다. 피부 보습 효과는 물론, 관절 내 윤활 작용에도 관여하여 움직임을 부드럽게 만들어줍니다. 일반적으로 하루 100~200mg의 섭취가 권장되며, 경구 보충제 형태로 제공됩니다.",
          positiveKeywords: [],
          negativeKeywords: []
        )
      ]
      for nut in dummyNutrients {
        context.insert(nut)
      }
      try? context.save()
      refreshID = UUID()
    }
  }
}

#Preview {
  RecommendView()
}
