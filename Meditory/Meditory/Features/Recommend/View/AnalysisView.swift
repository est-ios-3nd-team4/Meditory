import SwiftUI

struct AnalysisView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  let result: ScoreResult
  
  @State private var isAtTop = true

  var body: some View {
    VStack  {
      // 추후 수정부분
      ScrollView {
        VStack(alignment: .leading) {
          // 부족
          SectionChipsParagraphView(
            title: "부족 영양성분",
            chips: result.deficient,
            paragraph: result.summaries.deficient
          )
          .padding(.bottom, 16)

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
        .padding(.horizontal, 16)
      }
    }
    .background(
      ScrollTopObserver(isAtTop: $isAtTop)
    )
    .navigationBarHidden(true)
    .navigationBar(
      .aiAnalysisResult,
      backgroundStyle: .system,
      isAtTop: isAtTop
    )
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
        .font(.notoSans(weight: .bold, size: .defaultFontSize))
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
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
        .lineSpacing(4)
    }
  }
}
//#Preview {
struct AnalysisView_Previews: PreviewProvider {
  static var previews: some View {
    let dummyResult = ScoreResult(
      score: 75,
      counts: ScoreCounts(deficient: 2, caution: 1, optimal: 3, adequate: 4),
      deficient: ["비타민 D", "식이섬유"],
      caution: ["오메가3"],
      optimal: ["비타민 C", "칼슘", "아연"],
      adequate: ["마그네슘", "엽산", "철분", "비타민 B군"],
      summaries: AnalysisSummaries(
        deficient: "최근 식단에서 비타민 D와 식이섬유 섭취가 부족해 보입니다. 햇빛 노출과 채소, 과일, 통곡물 섭취를 늘리는 것이 권장됩니다.",
        caution: "오메가3 섭취는 충분하나 과잉 섭취 시 출혈 위험이 있을 수 있으므로 주의가 필요합니다.",
        optimal: "비타민 C, 칼슘, 아연 섭취는 양호합니다. 현재 패턴을 유지해 주세요.",
        adequate: "마그네슘, 엽산, 철분, 비타민 B군은 권장량에 근접한 수준으로 무난합니다."
      )
    )

    AnalysisView(result: dummyResult)
  }
}
