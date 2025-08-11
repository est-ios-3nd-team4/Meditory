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
        VStack(alignment: .leading, spacing: .smallSpacing) {
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
        .padding(.horizontal, 16)

        Divider()

        VStack(alignment: .leading, spacing: .defaultSpacing) {
          HStack {
            Text("🤟🏻 추천 영양성분")
              .font(.notoSans(weight: .bold, size: 15))
              .fontWeight(.bold)


            Text("3")
              .font(.notoSans(weight: .bold, size: 15))
              .fontWeight(.bold)
              .foregroundColor(.main)
          }
          .padding(.horizontal, 16)

          VStack(alignment: .leading, spacing: .smallSpacing) {
            Text("Tip")
              .fontWeight(.bold)
              .foregroundColor(Color.white)
              .padding(.horizontal, 8)
              .padding(.vertical, 4)
              .background(Color.main)
              .cornerRadius(.smallRadius)

            Text("추천하는 영양성분은 꼭 필요한 것만 추천되므로 아래 성분들을 모두 섭취하는것이 좋아요.")
              .font(.notoSans(weight: .medium, size: 15))
              .foregroundColor(Color.main)

          }
          .padding(12)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: .smallRadius)
              .fill(Color.sub.opacity(0.2))
          )
          .padding(.horizontal, 16)


          Divider()

          ForEach(nutrients, id: \.id) { nut in
            NutrientDetailSectionView(nutrient: nut)
              .padding(.horizontal, 16)
            Divider()
          }
        }
        .padding(.vertical)
      }
    }
    .navigationBarHidden(true)
    .scrollIndicators(.hidden)
  }
}

#Preview {
  RecommendNutrientsView()
}
