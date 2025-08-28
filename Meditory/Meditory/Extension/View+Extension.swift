//
//  View+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/13/25.
//

import SwiftUI

extension View {
  func cardStyle(padding: CGFloat = .zero, cornerRadius: CGFloat = 20)
    -> some View
  {
    self
      .modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
  }

  func longPressPopover<Content: View>(
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    modifier(LongPressPopoverModifier(popoverContent: content))
  }

  func navigationBar(
    _ title: NavigationTitle,
    backgroundStyle: PrimaryNavigationBar.BackgroundStyle = .custom,
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
          backgroundStyle: backgroundStyle,
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

  func adaptiveFont(
    _ baseSize: CGFloat,
    small: CGFloat = -2,
    plus: CGFloat = +2,
    weight: Font.NotoSansWeight = .regular
  ) -> some View {
    let size: CGFloat
    switch deviceWidthTier() {
    case .small:
      size = small
    case .regular:
      size = 0
    case .plus:
      size = plus
    }
    let finalSize = baseSize + size
    return self.font(.notoSans(weight: weight, size: finalSize))
  }
  
  func adaptiveImage(
    _ baseSize: CGFloat,
    small: CGFloat = -20,
    plus: CGFloat = +10
  ) -> some View {
    let size: CGFloat
    switch deviceWidthTier() {
    case .small:
      size = small
    case .regular:
      size = 0
    case .plus:
      size = plus
    }
    let side = max(16, baseSize + size)
    return self.frame(width: side, height: side)
  }
  
  func adaptivePadding(
    _ edge:Edge.Set,
    _ base: CGFloat,
    small: CGFloat = -2,
    plus: CGFloat = +2
  )->some View {
    let size: CGFloat
    switch deviceWidthTier() {
    case .small:
      size = small
    case .regular:
      size = 0
    case .plus:
      size = plus
    }
    let value = max(0, base + size)
    return self.padding(edge, value)
  }
  
}
