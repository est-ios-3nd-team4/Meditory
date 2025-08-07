import SwiftUI
import SwiftData

struct ScrapWrapper: View {
  var body: some View {
    NavigationStack {
      ScrapView()
    }
  }
}

struct ScrapView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.colorScheme) private var colorScheme

  @Query(sort: \Scrap.createdAt, order: .reverse)
  private var allScraps: [Scrap]

  @Query(sort: \Nutrient.name, order: .forward)
  private var allNutrients: [Nutrient]

  private var scrappedNutrients: [Nutrient] {
    allScraps.compactMap { scrap in
      allNutrients.first { $0.id == scrap.nutrientId }
    }
  }

  var body: some View {
    ScrollView {
          LazyVStack(spacing: 16) {
            ForEach(scrappedNutrients, id: \.id) { nutrient in
              NavigationLink(value: nutrient) {
                NutrientCardCell(nutrient: nutrient, colorScheme: colorScheme)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(16)
        }
        .navigationDestination(for: Nutrient.self) { nutrient in
          NutrientDetailSectionView(nutrient: nutrient)
            .padding(.horizontal, 16)
        }
      }
    }

struct NutrientCardCell: View {
  let nutrient: Nutrient
  let colorScheme: ColorScheme

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 6) {
        Text(nutrient.name)
          .font(.notoSans(weight: .medium, size: 15))

        // 해시태그 중 최대 2개 정도 보여주기
        HStack {
          ForEach(nutrient.hashtags.prefix(2), id: \.self) { tag in
            Text("#\(tag)")
              .font(.notoSans(weight: .medium, size: 12))
          }
        }
      }
      Spacer()
      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(colorScheme == .dark ? Color.white.opacity(0.3)
                    : Color.white)
    )
    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
  }
}

//#Preview {
//    ScrapView()
//}
