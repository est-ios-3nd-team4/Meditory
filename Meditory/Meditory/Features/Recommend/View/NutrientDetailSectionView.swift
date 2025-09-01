import SwiftUI
import SwiftData

/// 개별 영양소의 상세 정보를 표시하는 뷰
struct NutrientDetailSectionView: View {
  /// 표시할 영양소 모델
  @Bindable var nutrient: Nutrient
  /// SwiftData 모델 컨텍스트 (저장/삭제 등 DB 작업에 사용)
  @Environment(\.modelContext) private var context
  /// 현재 뷰를 닫기 위한 dismiss 환경값
  @Environment(\.dismiss) private var dismiss
  /// 현재 색상 모드 (다크/라이트)
  @Environment(\.colorScheme) private var colorScheme

  /// 기본 네비게이션 바 대신 커스텀 네비게이션 바를 표시할지 여부
  var showsCustomNavBar: Bool = false

  /// 저장된 전체 스크랩 목록 (최신순 정렬)
  @Query(sort: \Scrap.createdAt, order: .reverse)
  private var allScraps: [Scrap]

  /// 현재 영양소에 해당하는 스크랩만 필터링한 배열
  private var scraps: [Scrap] {
    allScraps.filter { $0.nutrientId == nutrient.id }
  }

  /// 공유 시 사용할 텍스트 (이름 + 해시태그 + 설명)
  private var shareText: String {
    let tags = nutrient.hashtags.isEmpty ? "" : "\n" + nutrient.hashtags.map { "#\($0)" }.joined(separator: " ")
    return """
    \(nutrient.name)\(tags)
    
    \(nutrient.title)
    
    \(nutrient.content)
    """
  }

  /// 영양소 카테고리에 따른 아이콘과 색상 스타일
  private var style: (symbol: String, color: Color) {
    RoutineIconResolver.style(category: nutrient.name, displayName: nutrient.name)
  }

  /// 현재 영양소를 스크랩에 추가하거나 제거하는 동작
  private func toggleScrap() {
    if let existing = scraps.first {
      // 이미 스크랩된 경우 삭제
      context.delete(existing)
    } else {
      // 없으면 새로 추가
      let new = Scrap(
        id: UUID().uuidString,
        userId: "dummy",
        nutrientId: nutrient.id
      )
      context.insert(new)
    }
    try? context.save()
  }

  /// 현재 영양소가 스크랩 상태인지 여부
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
            .font(.notoSans(weight: .bold, size: 30))

          Spacer()

          Button {
            toggleScrap()
          } label: {
            Image(systemName: isScrapped ? "star.fill" : "star")
          }
          .padding(.trailing, .smallSpacing)

          ShareLink(
            item: shareText,
            preview: SharePreview(nutrient.name, image: Image(systemName: "square.and.arrow.up"))
          ) {
            Image(systemName: "square.and.arrow.up")
              .frame(width: 44, height: 44)
              .contentShape(Rectangle())
          }
        }
        .padding(.bottom, .defaultSpacing)

        HStack {
          ForEach(nutrient.hashtags, id: \.self) { tag in
            Text("# \(tag)")
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
              .foregroundColor(.main)
          }
        }

        Text(nutrient.title)
          .font(.notoSans(weight: .regular, size: .defaultFontSize - 3))
          .padding(.vertical, .smallSpacing)

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
