//
//  FlowLayout2.swift
//
//	기존 FlowLayout 으로는 최대3줄 제한이 안되어서 새로 제작
//
//

import SwiftUI

struct FlowLayout2<Content: View>: View {
  let items: [String]
  let spacing: CGFloat
  let lineSpacing: CGFloat
  let lineLimit: Int?
  let content: (String) -> Content

  init(
    items: [String],
    spacing: CGFloat = 8,
    lineSpacing: CGFloat = 8,
    lineLimit: Int? = nil,
    @ViewBuilder content: @escaping (String) -> Content
  ) {
    self.items = items
    self.spacing = spacing
    self.lineSpacing = lineSpacing
    self.lineLimit = lineLimit
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

  private func makeRows(containerWidth: CGFloat) -> [[String]] {
    var result: [[String]] = []
    var currentRow: [String] = []
    var currentWidth: CGFloat = 0

    let maxWidth = containerWidth - 32

    for item in items {
      let itemWidth = textWidth(for: item) + 32
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
