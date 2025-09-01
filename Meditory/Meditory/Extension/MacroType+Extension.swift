//
//  MacroType+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import SwiftUI

/// `MacroType` 확장
/// - 각 영양소 타입(탄수화물, 단백질, 지방)에 대해 **UI 친화적인 속성**을 제공합니다.
/// - 뷰 코드에서 직접 `displayName`과 `color`를 참조하여 일관된 UI를 구현할 수 있습니다.
extension MacroType {
  /// 매크로 영양소의 한글 이름
  /// - `.carbohydrate` → "탄수화물"
  /// - `.protein` → "단백질"
  /// - `.fat` → "지방"
  var displayName: String {
    switch self {
    case .carbohydrate: return "탄수화물"
    case .protein: return "단백질"
    case .fat: return "지방"
    }
  }
  
  /// 매크로 영양소에 대응하는 고유 색상
  /// - 차트, 배지, 그래프 등에 사용됩니다.
  /// - `.carbohydrate` → `.customCarbohydrate`
  /// - `.protein` → `.customProtein`
  /// - `.fat` → `.customFat`
  var color: Color {
    switch self {
    case .carbohydrate: return .customCarbohydrate
    case .protein: return .customProtein
    case .fat: return .customFat
    }
  }
}
