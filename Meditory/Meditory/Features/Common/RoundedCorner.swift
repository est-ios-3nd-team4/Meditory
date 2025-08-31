//
//  RoundedCorner.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// **RoundedCorner**
///
/// SwiftUI 기본 `cornerRadius`는 **모든 모서리**에만 동일하게 적용되지만,
/// 이 `Shape`을 사용하면 특정 모서리만 선택적으로 둥글게 만들 수 있습니다.
///
/// - Parameters:
///   - `radius`: 둥글게 처리할 반지름 값 (기본값: `20`)
///   - `corners`: 둥글게 적용할 모서리 (`UIRectCorner`, 기본값: `.allCorners`)
struct RoundedCorner: Shape {
  var radius: CGFloat = 20
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
