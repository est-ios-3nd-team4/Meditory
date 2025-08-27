import SwiftUI
import SwiftData

struct RecommendNutrientsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  @State private var isLoading = false
  @State private var isAtTop = true

  let nutrients: [Nutrient]
  let displayName: String

  private var safeName: String {
    let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedDisplayName.isEmpty ? "사용자" : trimmedDisplayName
  }

  var body: some View {
    ScrollView {
      ScrollTopObserver(isAtTop: $isAtTop)

      VStack(alignment: .leading) {
        VStack(alignment: .leading, spacing: .smallSpacing) {
          Text("최종결과")
            .font(.notoSans(weight: .medium, size: 15))
            .foregroundColor(.gray)

          Text("\(safeName)님의")
            .font(.notoSans(weight: .bold, size: 25))
            .fontWeight(.bold)

          Text("식단을 고려한 추천하는 영양성분이에요.")
            .font(.notoSans(weight: .medium, size: 15))
            .fontWeight(.semibold)

          Text("* 본 결과는 의사의 처방을 대신하지 않습니다.")
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
              .multilineTextAlignment(.leading)

          }
          .padding(12)
          .frame(maxWidth: .infinity, alignment: .leading)
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
    .scrollIndicators(.hidden)
    .navigationBar(.none, backgroundStyle: .system, isAtTop: isAtTop)
  }
}

//#Preview {
//  RecommendNutrientsView()
//}
