import SwiftUI
import SwiftData

struct RecommendNutrientsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  @State private var nutrients: [Nutrient] = [
    Nutrient(
      id: "zinc",
      name: "아연",
      hashtags: ["정상적인 면역기능에 필요", "정상적인 세포분열에 필요"],
      description: "영양성분 설명",
      title: "아연은 면역기능에 필요한 필수 미네랄입니다.",
      content: "아연은 정상적인 세포성장, 생식 기능, 면역 등 체내 여러 활동에 필수적인 미량 영양성분으로...",
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

  var body: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
        }

        Spacer()

      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
    }
    .background(.clear)

    ScrollView {
      VStack(alignment: .leading) {
        VStack(alignment: .leading, spacing: 8) {
          Text("최종결과 2025.08.04")
            .font(.notoSans(weight: .medium, size: 15))
            .foregroundColor(.gray)

          Text("고객님의")
            .font(.notoSans(weight: .bold, size: 25))
            .fontWeight(.bold)

          Text("식단을 고려한 추천하는 영양성분이에요.")
            .font(.notoSans(weight: .medium, size: 15))
            .fontWeight(.semibold)

          Text("* 본결과는 의사의 처방을 대신하지 않습니다.")
            .font(.notoSans(weight: .medium, size: 15))
            .foregroundColor(.gray)
        }

        Divider()

        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Text("🤟🏻 추천 영양성분")
              .font(.notoSans(weight: .bold, size: 15))
              .fontWeight(.bold)


            Text("3")
              .font(.notoSans(weight: .bold, size: 15))
              .fontWeight(.bold)
              .foregroundColor(.main)
          }

          VStack(alignment: .leading, spacing: 8) {
            Text("Tip")
              .fontWeight(.bold)
              .foregroundColor(Color.white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.main)
              .cornerRadius(8)

            Text("추천하는 영양성분은 꼭 필요한 것만 추천되므로 아래 성분들을 모두 섭취하는것이 좋아요.")
              .font(.notoSans(weight: .medium, size: 15))
              .foregroundColor(Color.main)

          }
          .padding(12)
          .frame(maxWidth: .infinity)

          .background(Color.sub.opacity(0.2))
          .cornerRadius(8)

          Divider()

            ForEach(nutrients, id: \.id) { nut in
              NutrientDetailSectionView(nutrient: nut)
                .padding(.horizontal, 16)
              Divider()
            }
        }
        .padding(.vertical)



      }
      .padding(.horizontal, 16)
      .padding()
    }
    .navigationBarHidden(true)
    .scrollIndicators(.hidden)
  }
}

//#Preview {
//    RecommendNutrientsView()
//}
