import SwiftUI

struct AnalysisView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  let result: ScoreResult

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
            chips: result.deficient,
            paragraph: result.summaries.deficient
          )
          .padding(.vertical, 16)

          Divider()
          // 주의
          SectionChipsParagraphView(
            title: "주의 영양성분",
            chips: result.caution,
            paragraph: result.summaries.caution
          )
          .padding(.vertical, 16)

          Divider()
          // 최적
          SectionChipsParagraphView(
            title: "최적 영양성분",
            chips: result.optimal,
            paragraph: result.summaries.optimal
          )
          .padding(.vertical, 16)

          Divider()

          // 충족
          SectionChipsParagraphView(
            title: "충족 영양성분",
            chips: result.adequate,
            paragraph: result.summaries.adequate
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

//#Preview {
//  AnalysisView()
//}
