import SwiftUI
/// 하나의 영양소를 💊 아이콘과 함께 칩(Chip) 형태로 표시하는 뷰
struct NutrientChip: View {
  /// 표시할 영양소 이름
  let title: String

  var body: some View {
    Text("💊 \(title)")
      .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(Color.gray.opacity(0.5), lineWidth: 1)
      }
  }
}

/// 사용자 맞춤 영양소 추천을 카드 형태로 보여주는 뷰
struct NutrientCardView: View {
  /// 추천 영양소 목록
  let nutrients: [String]
  /// "상세보기" 버튼 클릭 시 호출되는 액션
  let onSeeDetail: () -> Void
  /// 로딩 상태 여부 (true일 경우 skeleton UI 표시)
  var isLoading: Bool = false
  /// 사용자 이름 (기본값: "사용자")
  var userName: String = "사용자"

  /// 현재 색상 모드 (다크/라이트)
  @Environment(\.colorScheme) private var colorScheme

  /// 공백/빈 문자열일 경우 기본값 `"사용자"`를 반환하는 안전한 이름
  private var safeName: String {
    let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? "사용자" : trimmed
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      // 헤더: 사용자 맞춤 타이틀 + 상세보기 버튼
      HStack {
        Text("\(safeName) 님 맞춤 영양소 추천")
          .font(.notoSans(weight: .medium, size: .defaultFontSize))

        Spacer()

        Button {
          onSeeDetail()
        } label: {
          Image(systemName: "chevron.right")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
        }
        .buttonStyle(PlainButtonStyle())
      }

      // 설명 텍스트
      Text("식단을 분석해 \(safeName) 님께 부족한 영양소를 추천드려요.")
        .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
        .foregroundColor(.gray)

      // 영양소 칩 목록 (로딩 시 Skeleton UI, 데이터 있으면 실제 칩)
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
    .padding(.defaultSpacing)
    .background(colorScheme == .dark ? Color.white.opacity(0.3)
                : Color.white)
    .cornerRadius(.defaultRadius)
  }
}
