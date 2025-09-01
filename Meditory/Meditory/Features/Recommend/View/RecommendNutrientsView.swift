import SwiftUI
import SwiftData

/// 식단 분석 결과를 기반으로 사용자의 맞춤 영양성분 추천을 보여주는 뷰
struct RecommendNutrientsView: View {
  /// 현재 뷰를 닫기 위한 dismiss 환경값
  @Environment(\.dismiss) private var dismiss
  /// 현재 색상 모드 (다크/라이트)
  @Environment(\.colorScheme) private var colorScheme

  /// 로딩 상태 여부
  @State private var isLoading = false
  /// 스크롤이 최상단에 위치해 있는지 여부
  @State private var isAtTop = true

  /// 추천된 영양소 목록
  let nutrients: [Nutrient]
  /// 사용자 이름
  let userName: String

  /// 공백/빈 문자열일 경우 `"사용자"`로 대체된 안전한 사용자 이름
  private var safeName: String {
    let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "사용자" : trimmed
  }

  var body: some View {
    ScrollView {
      // 스크롤 위치 감지 (상단 여부 추적)
      ScrollTopObserver(isAtTop: $isAtTop)

      VStack(alignment: .leading) {
        // 헤더: 최종결과 설명
        VStack(alignment: .leading, spacing: .smallSpacing) {
          Text("최종결과")
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
            .foregroundColor(.gray)

          Text("\(safeName) 님의")
            .font(.notoSans(weight: .bold, size: .defaultFontSize + 7))
            .fontWeight(.bold)

          Text("식단을 고려한 추천하는 영양성분이에요.")
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
            .fontWeight(.semibold)

          Text("* 본 결과는 의사의 처방을 대신하지 않습니다.")
            .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
            .foregroundColor(.gray)
        }
        .padding(.horizontal, .defaultSpacing)

        Divider()

        // 추천 영양소 섹션
        VStack(alignment: .leading, spacing: .defaultSpacing) {
          HStack {
            Text("🤟🏻 추천 영양성분")
              .font(.notoSans(weight: .bold, size: .defaultFontSize - 3))
              .fontWeight(.bold)


            Text("3")
              .font(.notoSans(weight: .bold, size: .defaultFontSize - 3))
              .fontWeight(.bold)
              .foregroundColor(.main)
          }
          .padding(.horizontal, .defaultSpacing)

          // Tip 카드
          VStack(alignment: .leading, spacing: .smallSpacing) {
            Text("Tip")
              .fontWeight(.bold)
              .foregroundColor(Color.white)
              .padding(.horizontal, .smallSpacing)
              .padding(.vertical, 4)
              .background(Color.main)
              .cornerRadius(.smallRadius)

            Text("추천하는 영양성분은 꼭 필요한 것만 추천되므로 아래 성분들을 모두 섭취하는것이 좋아요.")
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
              .foregroundColor(Color.main)
              .multilineTextAlignment(.leading)

          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
          .background(
            RoundedRectangle(cornerRadius: .smallRadius)
              .fill(Color.sub.opacity(0.2))
          )
          .padding(.horizontal, .defaultSpacing)


          Divider()

          ForEach(nutrients, id: \.id) { nut in
            NutrientDetailSectionView(nutrient: nut)
              .padding(.horizontal, .defaultSpacing)
            Divider()
          }
        }
        .padding(.vertical)
      }
    }
    .scrollIndicators(.hidden)
    .navigationBar(.none, backgroundStyle: .system, isAtTop: isAtTop)
  }
}

