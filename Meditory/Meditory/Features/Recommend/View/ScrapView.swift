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

  private func removeScrap(for nutrient: Nutrient) {
    if let scrap = allScraps.first(where: { $0.nutrientId == nutrient.id }) {
      withAnimation {
        context.delete(scrap)
        try? context.save()
      }
    }
  }

  var body: some View {
    ScrollView {
      LazyVStack(spacing: .defaultSpacing + 8) {
        ForEach(scrappedNutrients, id: \.id) { nutrient in
          NavigationLink(value: nutrient) {
            NutrientCardCell(nutrient: nutrient, colorScheme: colorScheme) {
              removeScrap(for: nutrient)
            }
          }
          .buttonStyle(.plain)
        }
      }
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
  let onUnscrap: () -> Void

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack {
          Text(nutrient.name)
            .font(.notoSans(weight: .medium, size: 15))

          Spacer()

          Button {
            onUnscrap()
          } label: {
            Image(systemName: "star.fill")
              .padding(.trailing, 8)
          }
        }

        // 해시태그 중 최대 2개 정도 보여주기
        HStack {
          ForEach(nutrient.hashtags.prefix(2), id: \.self) { tag in
            Text("#\(tag)")
              .font(.notoSans(weight: .medium, size: 12))
              .lineLimit(1)
          }
        }
      }
      Spacer()

      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: .defaultRadius)
        .fill(colorScheme == .dark ? Color.white.opacity(0.3)
              : Color.white)
    )
    .modifier(UnifiedShadow())
  }
}

//#Preview {
//    ScrapView()
//}
