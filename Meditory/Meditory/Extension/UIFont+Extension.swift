//
//  UIFont+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import UIKit

/// `UIFont` 확장 - NotoSansKR 폰트 사용 편의 제공
///
/// 앱 전반에서 일관된 **NotoSansKR 폰트**를 사용하기 위한 헬퍼 메서드를 정의합니다.
/// - `UIFont(name:size:)` 호출 시 문자열로 직접 지정하지 않고,
///   `NotoSansWeight` 열거형을 통해 가독성과 안정성을 높입니다.
extension UIFont {
  /// NotoSansKR 폰트 두께(Weight) 정의
  enum NotoSansWeight {
    /// 얇은 스타일 (Regular)
    case regular
    /// 기본 두께 (Medium)
    case medium
    /// 중간 굵기 (SemiBold)
    case semiBold
    /// 가장 굵은 스타일 (Bold)
    case bold
  }
  
  /// 지정한 두께와 크기로 `NotoSansKR` 폰트를 반환합니다.
  ///
  /// - Parameters:
  ///   - weight: 사용할 NotoSansKR 폰트 두께 (기본값: `.medium`)
  ///   - size: 폰트 크기 (pt 단위)
  /// - Returns: 요청한 NotoSansKR 폰트(`UIFont?`). 해당 폰트가 설치되어 있지 않으면 `nil`.
  static func notoSans(weight: NotoSansWeight = .medium, size: CGFloat) -> UIFont? {
    switch weight {
    case .regular:
      return UIFont(name: "NotoSansKR-Regular", size: size)
    case .medium:
      return UIFont(name: "NotoSansKR-Medium", size: size)
    case .semiBold:
      return UIFont(name: "NotoSansKR-SemiBold", size: size)
    case .bold:
      return UIFont(name: "NotoSansKR-Bold", size: size)
    }
  }
}
