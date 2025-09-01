//
//  CornerStyle.swift
//  Meditory
//
//  Created by 홍승아 on 8/19/25.
//

import Foundation

/// 뷰의 모서리 스타일을 정의하는 열거형
///
/// UI 컴포넌트에서 모서리 라운딩 방식을 일관되게 지정하기 위해 사용됩니다.
/// - `capsule`: 높이에 따라 자동으로 완전 캡슐 형태로 라운딩 처리합니다.
/// - `fixed(CGFloat)`: 지정한 고정 반경(`CGFloat`)으로 라운딩 처리합니다.
enum CornerStyle {
  /// 높이에 따라 자동으로 계산된 캡슐형 corner radius
  case capsule
  /// 고정된 값으로 지정된 corner radius
  case fixed(CGFloat)
}
