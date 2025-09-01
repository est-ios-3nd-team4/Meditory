//
//  UIDevice+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import UIKit

/// `UIDevice` 및 화면 크기 관련 확장/유틸 모음
extension UIDevice {
  /// 현재 기기가 iPad인지 여부를 반환합니다.
  ///
  /// - Returns: `true`이면 iPad, `false`이면 iPhone/iPod 등 다른 기기
  static var isPad: Bool {
    UIDevice.current.userInterfaceIdiom == .pad
  }
}

/// 화면 너비 기준으로 분류한 기기 크기 카테고리
/// - `.small`: iPhone SE, iPhone 12/13 mini 등 작은 화면 (≤ 375pt)
/// - `.regular`: 대부분의 일반 iPhone (376pt ~ 427pt)
/// - `.plus`: iPhone Plus/Pro Max 계열 (≥ 428pt)
enum widthSize {
  case small
  case regular
  case plus
}

/// 현재 디바이스의 화면 너비를 기반으로 크기 카테고리를 반환합니다.
/// - Returns: `widthSize` 값 (`.small`, `.regular`, `.plus`)
func deviceWidthSize() -> widthSize {
  let width = UIScreen.main.bounds.width
  if width <= 375 {
    return .small
  }
  if width >= 428 {
    return .plus
  }
  return .regular
}
