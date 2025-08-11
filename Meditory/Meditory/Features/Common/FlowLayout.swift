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

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

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

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        let maxWidth = bounds.width

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // 줄바꿈
            if x + size.width > bounds.maxX && x > bounds.minX {
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
