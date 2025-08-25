import SwiftUI

struct FlowLayoutLineLimit<Item: Hashable, ItemView: View>: View {
  // 1. 어떤 타입의 배열이든 받을 수 있도록 Item을 제네릭으로 변경
  let items: [Item]
  let itemFont: UIFont
  let spacing: CGFloat
  let lineSpacing: CGFloat
  let lineLimit: Int?
  let containerPadding: CGFloat
  let itemPadding: CGFloat
  let textProvider: (Item) -> String // 2. 너비 계산에 사용할 문자열을 item에서 추출하는 클로저
  let content: (Item) -> ItemView

  init(
    items: [Item],
    itemFont: UIFont = .systemFont(ofSize: 17), // 3. 아이템 폰트를 외부에서 주입받음
    spacing: CGFloat = 8,
    lineSpacing: CGFloat = 8,
    lineLimit: Int? = nil,
    containerPadding: CGFloat = 32,
    itemPadding: CGFloat = 32,
    textProvider: @escaping (Item) -> String, // 클로저 파라미터 추가
    @ViewBuilder content: @escaping (Item) -> ItemView
  ) {
    self.items = items
    self.itemFont = itemFont
    self.spacing = spacing
    self.lineSpacing = lineSpacing
    self.lineLimit = lineLimit
    self.containerPadding = containerPadding
    self.itemPadding = itemPadding
    self.textProvider = textProvider
    self.content = content
  }

  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .leading, spacing: lineSpacing) {
        ForEach(makeRows(containerWidth: geometry.size.width), id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(row, id: \.self) { item in
              content(item)
                .fixedSize() // 자식 뷰가 이상적인 크기를 갖도록 함
            }
            Spacer()
          }
        }
      }
    }
  }

  private func makeRows(containerWidth: CGFloat) -> [[Item]] {
    var result: [[Item]] = []
    var currentRow: [Item] = []
    var currentWidth: CGFloat = 0

    // 화면 전체 너비를 사용하되, 양쪽 끝에 최소한의 여유 공간만 둡니다.
    let maxWidth = containerWidth

    for item in items {
      // ⭐️ 수정된 부분: 텍스트 너비와 아이템 패딩을 더해서 실제 아이템 너비를 계산합니다.
      let itemWidth = textWidth(for: item) + itemPadding
      
      // 현재 줄에 아이템을 추가했을 때의 예상 너비
      let totalWidthWithSpacing = currentWidth + itemWidth + (currentRow.isEmpty ? 0 : spacing)

      // 예상 너비가 화면 너비를 초과하면 줄바꿈 처리
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

  private func textWidth(for item: Item) -> CGFloat {
    // 4. 주입받은 클로저와 폰트를 사용해 너비 계산
    let text = textProvider(item)
    let attributes = [NSAttributedString.Key.font: itemFont]
    let size = text.size(withAttributes: attributes)
    return size.width
  }
}
