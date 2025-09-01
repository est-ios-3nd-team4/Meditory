//
//  Food+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

/// `Food` 확장
/// - `Food` 엔티티를 UI 표시나 로직 처리에 적합한 `FoodInfo` DTO로 변환하는 기능을 제공합니다.
/// - 데이터베이스 모델(`Food`)과 뷰 모델 계층 간의 의존성을 줄이고,
///   필요한 정보만 추출하여 가볍게 전달할 수 있습니다.
extension Food {
  /// `Food` → `FoodInfo` 변환
  /// - Returns: `FoodInfo`
  ///   - `id`: `Food.id`
  ///   - `name`: 음식명 (`foodName`)
  ///   - `weight`: 총 중량 (`totalGram`)
  ///   - `macros`: 탄수화물/단백질/지방을 담은 `MacroNutrients`
  ///
  /// - Example:
  ///   ```swift
  ///   let food: Food = ...
  ///   let info = food.toFoodInfo()
  ///   print(info.name)   // "계란"
  ///   print(info.macros) // MacroNutrients(carbohydrate: 1.2, protein: 6.3, fat: 5.0)
  ///   ```
  func toFoodInfo() -> FoodInfo {
    return FoodInfo(
      id: id,
      name: foodName,
      weight: totalGram,
      macros: MacroNutrients(
        carbohydrate: carbohydrate,
        protein: protein,
        fat: fat
      )
    )
  }
}
