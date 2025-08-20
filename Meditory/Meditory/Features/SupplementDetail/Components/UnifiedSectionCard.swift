//
//  UnifiedSectionCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 앱 전반에서 통일된 카드 레이아웃
struct UnifiedSectionCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  let content: Content
  var pointColor: Color?
  var backgroundColor: Color?

  init(
    accentColor: Color? = nil,
    backgroundColor: Color? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.pointColor = accentColor
    self.backgroundColor = backgroundColor
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      content
    }
    .padding(.defaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .fixedSize(horizontal: false, vertical: true)
    .background(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .fill(
          backgroundColor ?? (
            colorScheme == .dark
            ? Color.white.opacity(0.08)
            : .white
          )
        )
    )
    .overlay(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .strokeBorder(
          pointColor?.opacity(0.3) ?? (
            colorScheme == .dark
            ? Color.white.opacity(0.15)
            : Color.black.opacity(0.1)
          ),
          lineWidth: 1
        )
    )
    .modifier(UnifiedShadow())
  }
}
#Preview {
  UnifiedSectionCard(accentColor: .main, backgroundColor: nil) {
    VStack {
      Text("테스트 뷰")
      Spacer()
      Text("텍스트")
    }
  }
}
