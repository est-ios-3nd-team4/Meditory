import SwiftUI

struct RecommendView: View {
  @State private var searchText = ""
  @State private var selectedScene: SceneTab = .recommend

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  @State private var didSeedNutrients = false

  enum SceneTab {
    case recommend
    case scrap
  }

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading) {
        ZStack(alignment: .trailing) {
          // 검색창
          TextField(
            "",
            text: $searchText,
            prompt: Text("영양성분 및 영양제를 검색해보세요!")
              .foregroundColor(.gray)
              .font(.notoSans(weight: .medium, size: 15))
          )
          .font(.notoSans(weight: .medium, size: 15))
          .foregroundColor(.black)
          .padding(.vertical, 8)
          .padding(.horizontal, 16)
          .background(Color.white)
          .cornerRadius(30)
          .padding(16)
          .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

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

        ZStack {
          RoundedRectangle(cornerRadius: 20)
            .fill(colorScheme == .dark ? Color.black : Color.white.opacity(0.98))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.bottom, -80)
            .ignoresSafeArea(.container, edges: .bottom)


          if selectedScene == .recommend {
            VStack {

              ScrollView {
                VStack {
                  // 맞춤 추천 셀
                  CardView(
                    title: "@@님 맞춤 추천",
                    categories: ["장 건강", "혈관 & 혈액순환"],
                    desciption: "혈관을 건강하게 하고, 혈액순환을 개선하는데 효과가 있어요.",
                    products: [
                      Product(imageName: "", brand: "스포츠리서치", name: "트리플 스트렝스 오메가3 피쉬오일"),
                      Product(imageName: "", brand: "동아제약", name: "써큐란 알파"),
                      Product(imageName: "", brand: "정관장", name: "홍삼정 에브리타임 10ml")
                    ]
                  )
                  .font(.notoSans(weight: .medium, size: 15))
                  .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                  .padding(16)

                  // 맞춤 영양소 추천 셀
                  NutrientCardView(nutrients: ["아연", "밀크씨슬", "히알루론산"])
                    .padding(.horizontal, 16)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                  ScoreView()
                    .padding(16)
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                }
              }
              .scrollIndicators(.hidden)
            }
          }

          else if selectedScene == .scrap {
            ScrapView()
              .padding(16)
              .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
          }
        }
      }
      .background(colorScheme == .dark ? Color.black : Color.main)
    }
    .onAppear {
            guard !didSeedNutrients else { return }
            didSeedNutrients = true

            let dummyNutrients = [
              Nutrient(
                id: "zinc",
                name: "아연",
                hashtags: ["정상적인 면역기능에 필요", "정상적인 세포분열에 필요"],
                description: "영양성분 설명",
                title: "아연은 면역에 필요한 미네랄입니다.",
                content: "아연은 정상적인 세포성장, 생식 기능, 면역 등에 필수적입니다.",
                positiveKeywords: [],
                negativeKeywords: []
              ),
              Nutrient(
                id: "milkthistle",
                name: "밀크씨슬",
                hashtags: ["간 건강에 도움을 줄 수 있음"],
                description: "영양성분 설명",
                title: "밀크씨슬 추출물은 간 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
                content: "밀크씨슬(Milk Thistle)은 국화과 식물로…",
                positiveKeywords: [],
                negativeKeywords: []
              ),
              Nutrient(
                id: "hyaluronic",
                name: "히알루론산",
                hashtags: ["피부 보습에 도움을 줄 수 있음", "관절 건강에 도움을 줄 수 있음"],
                description: "영양성분 설명",
                title: "히알루론산은 피부 보습과 관절 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
                content: "히알루론산은 인체 내에 존재하는 천연 물질로…",
                positiveKeywords: [],
                negativeKeywords: []
              )
            ]
            for nut in dummyNutrients {
              context.insert(nut)
            }
            try? context.save()
          }
  }
}

#Preview {
  RecommendView()
}
