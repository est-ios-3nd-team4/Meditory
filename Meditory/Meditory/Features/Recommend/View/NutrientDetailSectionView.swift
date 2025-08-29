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

  private var shareText: String {
    let tags = nutrient.hashtags.isEmpty ? "" : "\n" + nutrient.hashtags.map { "#\($0)" }.joined(separator: " ")
    return """
    \(nutrient.name)\(tags)

    \(nutrient.title)

    \(nutrient.content)
    """
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

    private let navHeight: CGFloat = 44

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
          .fill(.clear)
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
      .frame(height: navHeight)
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
          .padding(.trailing, 8)

          ShareLink(
            item: shareText,
            preview: SharePreview(nutrient.name, image: Image(systemName: "square.and.arrow.up"))
          ) {
            Image(systemName: "square.and.arrow.up")
              .frame(width: 44, height: 44)        
              .contentShape(Rectangle())
          }
        }
        .padding(.bottom, 16)

        HStack {
          ForEach(nutrient.hashtags, id: \.self) { tag in
            Text("# \(tag)")
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
              .foregroundColor(.main)
          }
        }

        Text(nutrient.title)
          .font(.notoSans(weight: .regular, size: .defaultFontSize - 3))
          .padding(.vertical, 8)

        Text(nutrient.content)
          .font(.notoSans(weight: .regular, size: .defaultFontSize - 3))
          .foregroundColor(.secondary)
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



