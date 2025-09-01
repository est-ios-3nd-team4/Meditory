//
//  Color+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// `Color` 확장: 앱 전반에서 공통적으로 사용하는 색상 정의 및 초기화 유틸
/// - UIKit의 `UIColor`를 래핑하거나, RGB(Int) 기반 초기화를 지원합니다.
/// - 디자인 시스템에서 반복되는 색상을 코드로 통일하여 일관성을 유지합니다.
extension Color {
  /// 시스템 기본 배경색 (`UIColor.systemBackground` 기반)
  static let background = Color(UIColor.systemBackground)

  /// 시스템 라벨 색상 (`UIColor.label` 기반)
  static let label = Color(UIColor.label)

  /// 차트/그래프 배경 색상 (연한 회색, RGB 239,239,239)
  static let chartBackground = Color(
    red: 239,
    green: 239,
    blue: 239,
    opacity: 1.0
  )

  /// RGB(Int) 기반 `Color` 초기화
  /// - Parameters:
  ///   - red: 0~255 범위의 빨강 값
  ///   - green: 0~255 범위의 초록 값
  ///   - blue: 0~255 범위의 파랑 값
  ///   - opacity: 불투명도 (기본값 1.0)
  /// - Example:
  ///   ```swift
  ///   let customBlue = Color(red: 30, green: 144, blue: 255)
  ///   ```
  init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
    self.init(
      .sRGB,
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      opacity: opacity
    )
  }
}
