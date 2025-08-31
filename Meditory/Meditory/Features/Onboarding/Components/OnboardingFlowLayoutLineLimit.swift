import SwiftUI

/// FlowLayout스타일 구현 공동 컴포넌트 뷰
struct OnboardingFlowLayoutLineLimit<Content: View>: View {
  
  // MARK: - 뷰 속성
  let items: [QuestionModel]
  let spacing: CGFloat
  let lineSpacing: CGFloat
  let lineLimit: Int?
  let containerPadding: CGFloat  // 화면 여백 파라미터
  let itemPadding: CGFloat  // 칩 패딩 파라미터
  let content: (QuestionModel) -> Content
  let isPad = UIDevice.isPad

  init(
    items: [QuestionModel],
    spacing: CGFloat = 8,
    lineSpacing: CGFloat = 8,
    lineLimit: Int? = nil,
    containerPadding: CGFloat = 32,  // 기본값 32 (좌우 16씩)
    itemPadding: CGFloat = 32,  // 기본값 32 (좌우 16씩)
    @ViewBuilder content: @escaping (QuestionModel) -> Content
  ) {
    self.items = items
    self.spacing = spacing
    self.lineSpacing = lineSpacing
    self.lineLimit = lineLimit
    self.containerPadding = containerPadding
    self.itemPadding = itemPadding
    self.content = content
  }

  // MARK: - 뷰 바디
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: lineSpacing) {
        ForEach(makeRows(containerWidth: isPad ? geometry.size.width * 0.8 : geometry.size.width), id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(row, id: \.self) { item in
              content(item)
                .lineLimit(nil)
                .fixedSize(horizontal: true, vertical: false)
            }
            Spacer()
          }
        }
      }
    }
  }

  /// 각 열을 구해서 반환하는 메소드
  private func makeRows(containerWidth: CGFloat) -> [[QuestionModel]] {
    var result: [[QuestionModel]] = []
    var currentRow: [QuestionModel] = []
    var currentWidth: CGFloat = 0

    let maxWidth = containerWidth - containerPadding

    for item in items {
      let itemWidth = textWidth(for: item.title) + itemPadding
      let totalWidthWithSpacing = currentWidth + itemWidth + (currentRow.isEmpty ? 0 : spacing)

      if totalWidthWithSpacing > maxWidth && !currentRow.isEmpty {
        result.append(currentRow)
        currentRow = [item]
        currentWidth = itemWidth
      } else {
        currentRow.append(item)
        currentWidth = totalWidthWithSpacing
      }
    }

    if !currentRow.isEmpty {
      result.append(currentRow)
    }

    if let limit = lineLimit {
      return Array(result.prefix(limit))
    }

    return result
  }

  /// 컨텐츠 텍스트의 너비를 구하는 메소드
  private func textWidth(for text: String) -> CGFloat {
    let font = UIFont.systemFont(ofSize: 17)
    let attributes = [NSAttributedString.Key.font: font]
    let size = text.size(withAttributes: attributes)
    return size.width
  }
}
