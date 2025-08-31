//
//  UIColor+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/14/25.
//

import UIKit

/// `UIColor` 확장
/// - RGB 정수값(0~255)과 불투명도(Double)를 사용해 손쉽게 `UIColor`를 생성할 수 있도록 도와줍니다.
/// - 코드 내에서 색상을 정의할 때 0~1 범위의 `CGFloat` 값으로 변환하는 번거로움을 줄여줍니다.
extension UIColor {
  /// 정수 기반 RGB 값과 불투명도를 이용해 `UIColor`를 초기화합니다.
  ///
  /// - Parameters:
  ///   - red: 빨강(Red) 값 (0~255)
  ///   - green: 초록(Green) 값 (0~255)
  ///   - blue: 파랑(Blue) 값 (0~255)
  ///   - opacity: 불투명도(Alpha, 0.0 ~ 1.0). 기본값은 `1.0`.
  ///
  /// - Example:
  ///   ```swift
  ///   let customColor = UIColor(red: 239, green: 239, blue: 239, opacity: 1.0)
  ///   ```
  convenience init(red: Int, green: Int, blue: Int, opacity: Double = 1.0) {
    self.init(
      red: Double(red) / 255,
      green: Double(green) / 255,
      blue: Double(blue) / 255,
      alpha: opacity
    )
  }
}
