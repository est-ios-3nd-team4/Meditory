import SwiftUI

/// 텍스트 기반 아이템들을 자동 줄바꿈하여 배치하는 커스텀 뷰.
///
/// `FlowLayout`과 유사하지만, 특정 `lineLimit`까지 줄 개수를 제한할 수 있고
/// 문자열 길이를 기반으로 아이템의 실제 너비를 계산하여 레이아웃을 구성합니다.
///
/// - 주요 특징:
///   - `items`: 어떤 타입이든(`Hashable`) 사용 가능
///   - `textProvider`: 아이템에서 문자열을 추출하는 클로저 (너비 계산에 사용)
///   - `content`: 각 아이템을 실제로 어떻게 렌더링할지 정의
///   - `lineLimit`: 최대 표시할 줄 수 (없으면 전체 표시)
///   - `itemFont`: 문자열 너비 계산에 사용될 폰트 (기본값: 시스템 17pt)
///   - `itemPadding`: 문자열 외부 여백 반영 (실제 뷰 너비 조정)
///
/// - 동작 방식:
///   1. `GeometryReader`를 이용해 컨테이너의 실제 가로 너비를 가져옵니다.
///   2. 각 아이템 문자열의 너비(`textWidth`) + `itemPadding`을 합산하여
///      현재 줄에 배치 가능한지 여부를 판단합니다.
///   3. 줄 너비를 초과하면 자동으로 **줄바꿈**하여 다음 줄에 배치합니다.
///   4. `lineLimit`가 지정되어 있다면 그 개수까지만 줄을 출력합니다.
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

  /// 컨테이너 너비에 맞춰 줄 단위로 아이템 분리
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

  /// 문자열 너비 계산
  private func textWidth(for item: Item) -> CGFloat {
    // 4. 주입받은 클로저와 폰트를 사용해 너비 계산
    let text = textProvider(item)
    let attributes = [NSAttributedString.Key.font: itemFont]
    let size = text.size(withAttributes: attributes)
    return size.width
  }
}
