import SwiftUI

struct AnalysisView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  private let lessChip = ["비타민 D", "식이섬유"]
  private let warningChip = ["오메가-6", "지방산"]
  private let optimalChip = ["오메가-3", "비타민 C"]
  private let meetChip = ["칼슘", "마그네슘"]

  

  var body: some View {
    VStack  {
      HStack {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
        }

        Spacer()

        Text("AI분석 전체 결과")
          .font(.notoSans(weight: .bold, size: 18))

        Spacer()

      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)


      // 추후 수정부분
      ScrollView {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
          // 부족
          Divider()

          SectionChipsParagraphView(
            title: "부족 영양성분",
            chips: lessChip,
            paragraph: """
                        분석 결과, 현재 식단이 육식 위주로 구성되어 있어 비타민 D와 식이섬유가 부족한 것으로 나타났습니다. 햇빛 노출을 늘리고, 통곡물·채소를 추가 섭취하시면 부족분 해소에 도움이 됩니다.
                        """
          )
          .padding(.vertical, 16)

          Divider()
          // 주의
          SectionChipsParagraphView(
            title: "주의 영양성분",
            chips: warningChip,
            paragraph: """
                        알레르기 반응이 있을 수 있는 견과류에 함유된 오메가-6 지방산은 과도 섭취 시 염증을 유발할 수 있습니다. 견과 알레르기가 있으시면 아몬드·호두·땅콩 등을 피하고, 대신 아마씨 오일 같은 대체 공급원을 고려하세요.
                        """
          )
          .padding(.vertical, 16)

          Divider()
          // 최적
          SectionChipsParagraphView(
            title: "최적 영양성분",
            chips: optimalChip,
            paragraph: """
                        현재 오메가-3, 비타민 C 섭취량이 권장량에 맞게 잘 유지되고 있습니다. 규칙적인 생선류 섭취와 제철 과일·채소 섭취 습관이 좋은 결과를 만들어 주고 있어요.
                        """
          )
          .padding(.vertical, 16)

          Divider()

          // 충족
          SectionChipsParagraphView(
            title: "충족 영양성분",
            chips: meetChip,
            paragraph: """
                        칼슘과 마그네슘 섭취량이 권장 수준을 충분히 넘어섰습니다. 뼈 건강과 근육 이완에 기여하고 있으니, 이 상태를 유지해 주시면 좋습니다.
                        """
          )
          .padding(.vertical, 16)

          Divider()

        }
        .padding(16)
      }
    }
    .navigationBarHidden(true)
  }
}


private struct SectionChipsParagraphView: View {
  
  let title: String
  let chips: [String]
  let paragraph: String

  var titleColor: Color {
    switch title {
    case "부족 영양성분":
      return .red
    case "주의 영양성분":
      return .yellow
    case "최적 영양성분":
      return .blue
    case "충족 영양성분":
      return .green
    default:
      return .primary
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      Text(title)
        .font(.notoSans(weight: .bold, size: 18))
        .foregroundColor(titleColor)

      // 칩을 가로 스크롤로 나열
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: .smallSpacing) {
          ForEach(chips, id: \.self) { chip in
            NutrientChip(title: chip)
          }
        }
      }

      // 설명 문단
      Text(paragraph)
        .font(.notoSans(weight: .medium, size: 15))
        .lineSpacing(4)
    }
  }
}

#Preview {
  AnalysisView()
}
