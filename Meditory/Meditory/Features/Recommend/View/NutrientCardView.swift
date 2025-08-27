import SwiftUI

struct NutrientChip: View {
  let title: String

  var body: some View {
    Text("💊 \(title)")
      .font(.notoSans(weight: .medium, size: 15))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(Color.gray.opacity(0.5), lineWidth: 1)
      }
  }
}

struct NutrientCardView: View {
  let nutrients: [String]
  let onSeeDetail: () -> Void
  var isLoading: Bool = false
  var displayName: String = "사용자"

  @Environment(\.colorScheme) private var colorScheme

  private var safeName: String {
    let trimmedDisplayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedDisplayName.isEmpty ? "사용자" : trimmedDisplayName
  }
  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      HStack {
        Text("\(safeName) 님 맞춤 영양소 추천")
          .font(.notoSans(weight: .medium, size: 18))

        Spacer()

        Button {
          onSeeDetail()
        } label: {
          Image(systemName: "chevron.right")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
        }
        .buttonStyle(PlainButtonStyle())
      }

      Text("식단을 분석해 \(safeName) 님께 부족한 영양소를 추천드려요.")
        .font(.notoSans(weight: .medium, size: 12))
        .foregroundColor(.gray)

      FlowLayout(spacing: .smallSpacing, lineSpacing: .smallSpacing) {
        if isLoading || nutrients.isEmpty {
          let skeletonCount = 3
          let skeletonWidth: CGFloat = 80

          ForEach(0..<skeletonCount, id: \.self) { _ in
            NutrientChipSkeleton(width: skeletonWidth)
          }
        } else {
          ForEach(nutrients, id: \.self) { nutrient in
            NutrientChip(title: nutrient)
              .lineLimit(1)
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }
        }
      }
      .animation(.easeInOut(duration: 0.2), value: isLoading || nutrients.isEmpty)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(colorScheme == .dark ? Color.white.opacity(0.3)
                : Color.white)
    .cornerRadius(.defaultRadius)
  }
}

//#Preview {
//  NutrientCardView(nutrients: ["아연", "밀크씨슬", "히알루론산"])
//}
