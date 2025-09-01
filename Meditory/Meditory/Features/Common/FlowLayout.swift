// 텍스트처럼 뷰를 배치하는 FlowLayout
// 사용법 예시
//
//  FlowLayout(spacing: 8, lineSpacing: 8) {
//    ForEach(items, id: \.self) { item in
//      Text(item)
//        .padding(8)
//    }
//  }



import SwiftUI

/// 텍스트나 뷰들을 자동 줄바꿈 되도록 배치하는 `Layout`
///
/// 일반 `HStack`은 화면 너비를 초과하면 잘려 보이지만,
/// `FlowLayout`은 **최대 가용 너비를 초과할 경우 자동으로 줄바꿈**하여
/// 여러 줄로 뷰를 배치할 수 있습니다.
///
/// - 주요 특징:
///   - `spacing`: 같은 줄 안에서 뷰 간 간격
///   - `lineSpacing`: 줄과 줄 사이의 간격
struct FlowLayout: Layout {
  /// 같은 줄 내에서 뷰 간 간격
  var spacing: CGFloat = 8
  /// 줄 간 간격
  var lineSpacing: CGFloat = 8
  
  /// 레이아웃 전체 크기를 계산
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    var width: CGFloat = 0
    var height: CGFloat = 0
    var lineHeight: CGFloat = 0
    let maxWidth = proposal.width ?? .infinity
    
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      
      if width + size.width > maxWidth && width > 0 {
        // 줄바꿈
        width = 0
        height += lineHeight + lineSpacing
        lineHeight = 0
      }
      
      width += size.width + spacing
      lineHeight = max(lineHeight, size.height)
    }
    
    // 마지막 줄 반영
    height += lineHeight
    return CGSize(width: maxWidth, height: height)
  }
  
  /// 실제 뷰들을 배치
  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var x: CGFloat = bounds.minX
    var y: CGFloat = bounds.minY
    var lineHeight: CGFloat = 0
    let maxWidth = bounds.width // ✅ 이제 실제로 사용됨
    
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      
      // 줄바꿈
      if x + size.width > maxWidth + bounds.minX && x > bounds.minX {
        x = bounds.minX
        y += lineHeight + lineSpacing
        lineHeight = 0
      }
      
      subview.place(at: CGPoint(x: x, y: y),
                    proposal: ProposedViewSize(size))
      x += size.width + spacing
      lineHeight = max(lineHeight, size.height)
    }
  }
}
