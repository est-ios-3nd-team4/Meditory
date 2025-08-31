//
//  MacroNutrients.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

/// `MacroNutrients` 확장
/// - 영양소 데이터(탄수화물, 단백질, 지방)를 **UI 표시용 아이템 배열**로 변환하거나,
///   동등성 비교를 지원하기 위한 기능을 제공합니다.
extension MacroNutrients {
  /// `MacroNutrients` → `[MacroItem]` 변환
  /// - `MacroType.allCases`(carb, protein, fat)에 대해 각각 `MacroItem`을 생성합니다.
  /// - 뷰 단에서는 `macroItems`를 순회하여 영양 성분을 일관되게 표시할 수 있습니다.
  ///
  /// - Example:
  ///   ```swift
  ///   let macros = MacroNutrients(carbohydrate: 50, protein: 20, fat: 10)
  ///   for item in macros.macroItems {
  ///     print("\(item.label): \(item.gram)g")
  ///   }
  ///   // 출력: 탄수화물: 50g, 단백질: 20g, 지방: 10g
  ///   ```
  var macroItems: [MacroItem] {
    MacroType.allCases.map { type in
      MacroItem(type: type, gram: self[type])
    }
  }
}

/// `MacroNutrients`를 `Equatable`로 확장
/// - 탄수화물, 단백질, 지방 값이 모두 동일할 때 같은 값으로 간주합니다.
extension MacroNutrients: Equatable {
  static func == (lhs: MacroNutrients, rhs: MacroNutrients) -> Bool {
    return lhs.carbohydrate == rhs.carbohydrate &&
    lhs.protein == rhs.protein &&
    lhs.fat == rhs.fat
  }
}
