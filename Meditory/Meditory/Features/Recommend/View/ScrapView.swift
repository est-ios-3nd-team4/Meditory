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
      NutrientDetailSectionView(nutrient: nutrient, showsCustomNavBar: true)
        .padding(.horizontal, 16)
    }
  }
}

struct NutrientCardCell: View {
  let nutrient: Nutrient
  let colorScheme: ColorScheme
  let onUnscrap: () -> Void
  private var style: (symbol: String, color: Color) {
    RoutineIconResolver.style(category: nutrient.name, displayName: nutrient.name)
  }

  var body: some View {
    HStack(spacing: .defaultSpacing) {
      Image(systemName: style.symbol)
        .imageScale(.medium)
        .padding(.smallSpacing)
        .background(
          Circle()
            .fill(style.color.opacity(0.15))
        )
        .foregroundStyle(style.color)
        .accessibilityHidden(true)

      Text(nutrient.name)
        .font(.notoSans(size: .defaultFontSize))
        .fontWeight(.bold)
        .lineLimit(1)
        .minimumScaleFactor(0.85)

      Spacer()
    }
    .padding(.defaultSpacing)
    .background(
      RoundedRectangle(cornerRadius: .defaultRadius)
        .fill(colorScheme == .dark ? Color.white.opacity(0.28) : Color.white)
    )
    .modifier(UnifiedShadow())
  }
}

//#Preview {
//    ScrapView()
//}
