import SwiftUI

struct NutrientChipSkeleton: View {
  @Environment(\.colorScheme) private var colorScheme

  let width: CGFloat
  private let height: CGFloat = 30

  var body: some View {
    ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(.defaultRadius))
      .frame(width: width, height: height)
  }
}

struct LoadingChip: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: 8) {
      ProgressView().scaleEffect(0.8)
      Text("로딩 중")
        .font(.system(size: 15, weight: .medium))
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(
      Capsule().fill(colorScheme == .dark
                     ? Color.white.opacity(0.15)
                     : Color(.systemGray6))
    )
    .foregroundColor(colorScheme == .dark ? .white : .primary)
    .accessibilityLabel("맞춤 영양 성분 로딩 중")
  }
}
