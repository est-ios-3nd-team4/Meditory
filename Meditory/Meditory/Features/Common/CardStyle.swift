//
//  CardStyle.swift
//  Meditory
//
//  Created by 홍승아 on 8/13/25.
//

import SwiftUI

struct CardStyle: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme
  var padding: CGFloat = .zero
  var cornerRadius: CGFloat = 20

  func body(content: Content) -> some View {
    content
      .padding(padding)
      .background(
        colorScheme == .dark
        ? Color.white.opacity(0.3)
        : Color.white
      )
      .cornerRadius(cornerRadius)
      .modifier(UnifiedShadow())
  }
}
