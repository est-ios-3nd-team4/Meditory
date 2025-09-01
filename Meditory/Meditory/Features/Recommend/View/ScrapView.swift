import SwiftUI
import SwiftData

/// 스크랩 뷰를 `NavigationStack`으로 감싸는 래퍼 뷰
struct ScrapWrapper: View {
  var body: some View {
    NavigationStack {
      ScrapView()
    }
  }
}

/// 사용자가 스크랩한 영양소 목록을 표시하는 뷰
struct ScrapView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.colorScheme) private var colorScheme

  /// 저장된 모든 스크랩 (최신순)
  @Query(sort: \Scrap.createdAt, order: .reverse)
  private var allScraps: [Scrap]

  /// 저장된 모든 영양소 (이름순)
  @Query(sort: \Nutrient.name, order: .forward)
  private var allNutrients: [Nutrient]

  /// 스크랩에 해당하는 영양소 객체 목록
  private var scrappedNutrients: [Nutrient] {
    allScraps.compactMap { scrap in
      allNutrients.first { $0.id == scrap.nutrientId }
    }
  }

  /// 특정 영양소의 스크랩을 해제
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
    // 네비게이션 딥링크: 영양소 클릭 시 상세 화면 이동
    .navigationDestination(for: Nutrient.self) { nutrient in
      NutrientDetailSectionView(nutrient: nutrient, showsCustomNavBar: true)
        .padding(.horizontal, .defaultSpacing)
    }
  }
}

/// 개별 영양소를 카드 형태로 표시하는 셀
struct NutrientCardCell: View {
  /// 표시할 영양소
  let nutrient: Nutrient
  /// 다크/라이트 모드
  let colorScheme: ColorScheme
  /// 스크랩 해제 액션
  let onUnscrap: () -> Void

  /// 영양소 이름 기반 스타일 (아이콘/색상)
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
