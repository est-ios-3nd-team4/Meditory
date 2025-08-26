//
//  UnifiedSectionCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 앱 전반에서 통일된 카드 레이아웃
/// - 배경색, 그림자, 외곽선 등을 옵션으로 제어 가능
struct UnifiedSectionCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  let content: Content // 카드 내부에 표시할 뷰

  var pointColor: Color?   // 강조 색상 (stroke 등에서 사용)
  var backgroundColor: Color? // 카드 배경 색상
  var showsStroke: Bool  // 외곽선(stroke) 표시 여부
  var showShadow: Bool // 그림자 표시 여부

  init(
    pointColor: Color? = nil,
    backgroundColor: Color? = nil,
    showsStroke: Bool = true,
    showShadow: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.pointColor = pointColor
    self.backgroundColor = backgroundColor
    self.showsStroke = showsStroke
    self.showShadow = showShadow
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      content
    }
    .padding(.defaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .fixedSize(horizontal: false, vertical: true)
    .background(
      (backgroundColor ?? (
        colorScheme == .dark ? Color.white.opacity(0.3) : Color.white
      ))
    )
    .clipShape(
      RoundedRectangle(
        cornerRadius: .defaultRadius,
        style: .continuous
      )
    )
    .overlay(
      Group {
        if showsStroke {
          RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
            .strokeBorder(
              pointColor?.opacity(0.3) ?? (
                colorScheme == .dark
                ? Color.white.opacity(0.15)
                : Color.black.opacity(0.1)
              ),
              lineWidth: 1
            )
        }
      }
    )
    .modifier(UnifiedShadow(enabled: showShadow))
  }
}
#Preview("stroke") {
  UnifiedSectionCard(pointColor: .main, backgroundColor: nil, showsStroke: false) {
    VStack {
      Text("테스트 뷰")
      Spacer()
      Text("텍스트")
    }
  }
}
#Preview("not") {
  UnifiedSectionCard(pointColor: .main, backgroundColor: nil, showsStroke: false, showShadow: false) {
    VStack {
      Text("테스트 뷰")
      Spacer()
      Text("텍스트")
    }
  }
}
