import SwiftUI

/// 영양 성분 칩 로딩 상태를 표시하기 위한 스켈레톤 뷰.
/// - `ShimmerView`를 사용하여 깜빡이는 효과를 제공.
/// - 실제 데이터 로딩 전 placeholder 용도로 사용된다.
struct NutrientChipSkeleton: View {
  @Environment(\.colorScheme) private var colorScheme

  /// 칩의 가로 길이
  let width: CGFloat
  /// 칩의 고정 세로 길이 (기본 30)
  private let height: CGFloat = 30

  var body: some View {
    ShimmerView(widthRatio: 1.0, cornerRadius: .fixed(.defaultRadius))
      .frame(width: width, height: height)
  }
}

/// 로딩 중임을 칩 형태로 표시하는 뷰.
/// - ProgressView 아이콘과 "로딩 중" 텍스트를 함께 표시.
/// - 다크 모드/라이트 모드에 따라 배경색과 전경색이 조정된다.
struct LoadingChip: View {
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: .smallSpacing) {
      ProgressView().scaleEffect(0.8)
      Text("로딩 중")
        .font(.system(size: 15, weight: .medium))
    }
    .padding(.horizontal, .defaultSpacing)
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
