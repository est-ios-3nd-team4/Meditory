//
//  ScrollOffsetKey.swift
//  Meditory
//
//  Created by 홍승아 on 8/24/25.
//

import SwiftUI

/// 스크롤 위치를 추적하기 위한 PreferenceKey
struct ScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}
