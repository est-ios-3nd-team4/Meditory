import SwiftUI
import SwiftData

struct NutrientDetailSectionView: View {
  @Bindable var nutrient: Nutrient
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

  var showsCustomNavBar: Bool = false

  @Query(sort: \Scrap.createdAt, order: .reverse)
  private var allScraps: [Scrap]

  private var scraps: [Scrap] {
    allScraps.filter { $0.nutrientId == nutrient.id }
  }

  private func toggleScrap() {
    if let existing = scraps.first {
      context.delete(existing)
    } else {
      let new = Scrap(
        id: UUID().uuidString,
        userId: "dummy",
        nutrientId: nutrient.id
      )
      context.insert(new)
    }
    try? context.save()
  }

  private var isScrapped: Bool { !scraps.isEmpty }

  private struct CustomNavBarModifier: ViewModifier {
    let enabled: Bool
    let title: String
    let onBack: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    @ViewBuilder
    func body(content: Content) -> some View {
      if enabled {
        content
          .navigationBarBackButtonHidden(true)
          .toolbar(.hidden, for: .navigationBar)
          .safeAreaInset(edge: .top, spacing: 0) { bar }
      } else { content }
    }

    private var bar: some View {
      ZStack {
        // 배경을 좌우 끝까지
        Rectangle()
          .fill(.customBackground)
          .ignoresSafeArea(edges: .horizontal)

        HStack {
          Button(action: onBack) {
            Image(systemName: "chevron.left")
              .font(.title3)
              .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
          }
          Spacer()
        }
        .padding(.leading, 0)
        .padding(.trailing, 0)
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack {
          Text("🧪 \(nutrient.name)")
            .font(.notoSans(weight: .bold, size: 30))


          Spacer()

          Button {
            toggleScrap()
          } label: {
            Image(systemName: isScrapped ? "star.fill" : "star")
          }
        }
        .padding(.bottom, 16)

        ForEach(nutrient.hashtags, id: \.self) { tag in
          Text("# \(tag)")
            .font(.notoSans(weight: .bold, size: 15))
        }

        Text(nutrient.title)
          .font(.notoSans(weight: .medium, size: 15))
          .padding(.vertical, 8)

        Text(nutrient.content)
          .font(.notoSans(weight: .medium, size: 15))
      }
      .padding(.vertical)
    }
    .scrollIndicators(.hidden)
    .modifier(CustomNavBarModifier(
      enabled: showsCustomNavBar,
      title: nutrient.name,
      onBack: { dismiss() }
    ))
  }
}



