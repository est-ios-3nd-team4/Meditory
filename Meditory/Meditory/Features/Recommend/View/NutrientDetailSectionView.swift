import SwiftUI
import SwiftData

struct NutrientDetailSectionView: View {
  @Bindable var nutrient: Nutrient
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

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

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack {
          Text(nutrient.name)
            .font(.notoSans(weight: .bold, size: 30))
            .fontWeight(.bold)

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
            .fontWeight(.bold)
        }

        Text("🧪 \(nutrient.desc)")
          .font(.notoSans(weight: .bold, size: 18))
          .fontWeight(.bold)
          .padding(.vertical, 16)

        Text(nutrient.title)
          .font(.notoSans(weight: .bold, size: 15))
          .fontWeight(.bold)
          .padding(.bottom, 8)

        Text(nutrient.content)
          .font(.notoSans(weight: .medium, size: 15))
      }
      .padding(.vertical)
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarBackButtonHidden(true)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }
        }
      }
    }
    .scrollIndicators(.hidden)
  }
}


