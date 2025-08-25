//
//  View+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/13/25.
//

import SwiftUI

extension View {
  func cardStyle(padding: CGFloat = .zero, cornerRadius: CGFloat = 20) -> some View {
    self
      .modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
  }
  
  func navigationBar(
    _ title: NavigationTitle,
    isAtTop: Bool? = nil,
    _ onBackTap: (() -> Void)? = nil
  ) -> some View {
    self
      .navigationBarHidden(true)
      .applyIf(isAtTop != nil) {
        $0.coordinateSpace(CoordinateSpaceName.scroll.coordinateSpace)
      }
      .safeAreaInset(edge: .top) {
        PrimaryNavigationBar(
          title: title,
          isAtTop: isAtTop,
          onBackTap: onBackTap
        )
      }
  }
  
  @ViewBuilder
  func applyIf<M: ViewModifier>(
    _ condition: Bool,
    modifier: M
  ) -> some View {
    if condition {
      self.modifier(modifier)
    } else {
      self
    }
  }
  
  @ViewBuilder
  func applyIf<Content: View>(
    _ condition: Bool,
    @ViewBuilder transform: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}
