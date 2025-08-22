import SwiftUI

struct NutrientChipSkeleton: View {
  @Environment(\.colorScheme) private var colorScheme

  let width: CGFloat
  private let height: CGFloat = 30

  var body: some View {
    ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(.defaultRadius))
      .frame(width: width, height: height)
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(Color.gray.opacity(0.5), lineWidth: 1)
      }
  }
}
