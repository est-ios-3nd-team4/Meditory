import SwiftUI

struct OnboardingFlowLayoutLineLimit<Content: View>: View {
  let items: [QuestionModel]
  let spacing: CGFloat
  let lineSpacing: CGFloat
  let lineLimit: Int?
  let containerPadding: CGFloat  // 화면 여백 파라미터
  let itemPadding: CGFloat  // 칩 패딩 파라미터
  let content: (QuestionModel) -> Content

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

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: lineSpacing) {
        ForEach(makeRows(containerWidth: geometry.size.width), id: \.self) { row in
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

  private func textWidth(for text: String) -> CGFloat {
    let font = UIFont.systemFont(ofSize: 17)
    let attributes = [NSAttributedString.Key.font: font]
    let size = text.size(withAttributes: attributes)
    return size.width
  }
}
