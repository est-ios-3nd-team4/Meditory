//
//  Font+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

/// `Font` 확장
/// - 앱 전반에서  NotoSansKR 폰트 패밀리를 손쉽게 사용할 수 있도록 도와줍니다.
/// - `weight`와 `size`를 지정해 일관된 타이포그래피 스타일을 적용할 수 있습니다.
extension Font {
  /// NotoSansKR 폰트 두께 정의
  enum NotoSansWeight {
    /// 얇은 일반체 (Regular)
    case regular
    /// 기본 굵기 (Medium)
    case medium
    /// SemiBold
    case semiBold
    /// Bold
    case bold
  }
  
  /// NotoSansKR 커스텀 폰트를 생성
  /// - Parameters:
  ///   - weight: 사용할 두께 (기본값 `.medium`)
  ///   - size: 폰트 크기
  /// - Returns: 지정된 가중치와 크기의 `Font`
  ///
  /// - Example:
  ///   ```swift
  ///   Text("Hello")
  ///     .font(.notoSans(weight: .bold, size: 20))
  ///   ```
  static func notoSans(weight: NotoSansWeight = .medium, size: CGFloat) -> Font {
    switch weight {
    case .regular:
      return custom("NotoSansKR-Regular", size: size)
    case .medium:
      return custom("NotoSansKR-Medium", size: size)
    case .semiBold:
      return custom("NotoSansKR-SemiBold", size: size)
    case .bold:
      return custom("NotoSansKR-Bold", size: size)
    }
  }
}
