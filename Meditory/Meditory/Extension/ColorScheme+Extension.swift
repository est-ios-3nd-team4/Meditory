//
//  ColorScheme+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/25/25.
//

import SwiftUI

/// `ColorScheme` 확장
/// - 다크 모드/라이트 모드 여부를 쉽게 확인할 수 있는 편의 프로퍼티를 제공합니다.
/// - 뷰 코드에서 `if colorScheme.isDarkMode { ... }` 와 같이 직관적으로 사용할 수 있습니다.
extension ColorScheme {
  /// 현재 환경이 다크 모드인지 여부
  var isDarkMode: Bool { self == .dark }
  
  /// 현재 환경이 라이트 모드인지 여부
  var isLightMode: Bool { self == .light }
}
