//
//  MacroItem+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import SwiftUI

/// `MacroItem` 확장
/// - 각 매크로 영양소 항목(`MacroItem`)에 대해 UI 표시용 속성을 제공합니다.
/// - 뷰 코드에서 `label`과 `color`를 직접 참조할 수 있어
///   매번 타입별 분기 처리를 하지 않고 일관성 있는 UI를 구성할 수 있습니다.
extension MacroItem {
  /// 매크로 영양소의 표시 이름 (예: 탄수화물, 단백질, 지방)
  var label: String { type.displayName }

  /// 매크로 영양소에 대응하는 색상 (그래프/차트 등 시각화에서 사용)
  var color: Color { type.color }
}
