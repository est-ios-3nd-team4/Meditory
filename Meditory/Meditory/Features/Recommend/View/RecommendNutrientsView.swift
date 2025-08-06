import SwiftUI

struct RecommendNutrientsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  let nutrients = ["아연", "밀크씨슬", "히알루론산"]
  
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
          
          
          HStack {
            ForEach(nutrients, id: \.self) { nut in
              NutrientChip(title: nut)
            }
          }
        }
        .padding(.vertical)
        
        Divider()
        
        NutrientDetailSectionView(
          name: "아연",
          tags: ["정상적인 면역기능에 필요", "정상적인 세포분열에 필요"],
          descriptionTitle: "영양성분 설명",
          summary: "아연은 면역기능에 필요한 필수 미네랄입니다.",
          detail: "아연은 정상적인 세포성장, 생식 기능, 면역 등 체내 여러 활동에 필수적인 미량 영양성분으로..."
        )
        
        
        Divider()
        
        NutrientDetailSectionView(
          name: "밀크씨슬",
          tags: ["간 건강에 도움을 줄 수 있음"],
          descriptionTitle: "영양성분 설명",
          summary: "밀크씨슬 추출물은 간 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
          detail: "밀크씨슬(Milk Thistle)은 국화과 식물로, 실리마린(Silymarin)이라는 플라보노이드 복합체를 함유하고 있습니다. 실리마린은 간 세포막을 안정화하고, 간 세포의 재생을 돕는 것으로 알려져 있습니다. 또한, 항산화 작용을 통해 간을 유해물질로부터 보호하는 데 도움을 줄 수 있습니다. 밀크씨슬 추출물은 식품의약품안전처로부터 '간 건강에 도움을 줄 수 있음'이라는 기능성을 인정받았습니다."
        )
        
        Divider()
        
        NutrientDetailSectionView(
          name: "히알루론산",
          tags: ["피부 보습에 도움을 줄 수 있음", "관절 건강에 도움을 줄 수 있음"],
          descriptionTitle: "영양성분 설명",
          summary: "히알루론산은 피부 보습과 관절 건강에 도움을 줄 수 있는 건강기능식품 기능성 원료입니다.",
          detail: "히알루론산은 인체 내에 존재하는 천연 물질로, 자기 무게의 수백 배에 달하는 수분을 끌어당기는 강력한 보습력을 가지고 있습니다. 주로 피부, 관절액, 눈 등에 분포하며, 피부의 촉촉함과 탄력을 유지하고 관절의 윤활 작용을 돕는 역할을 합니다. 건강기능식품으로서 히알루론산은 식품의약품안전처로부터 '피부 보습에 도움을 줄 수 있음'과 '관절 건강에 도움을 줄 수 있음'이라는 기능성을 인정받았습니다."
        )
      }
      .padding(.horizontal, 16)
      .padding()
    }
    .navigationBarHidden(true)
  }
}

//#Preview {
//    RecommendNutrientsView()
//}
