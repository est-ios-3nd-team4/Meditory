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
}
