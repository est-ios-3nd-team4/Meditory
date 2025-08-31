//
//  FoodInfo+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

/// `FoodInfo` 확장
/// - `FoodInfo` DTO를 실제 데이터 모델(`Food`)로 변환하는 기능을 제공합니다.
/// - 뷰/네트워크 계층에서 사용되는 경량 객체(`FoodInfo`)를
///   저장/영속 계층에서 다루는 엔티티(`Food`)로 다시 변환할 때 활용됩니다.
extension FoodInfo {
  /// `FoodInfo` → `Food` 변환
  /// - Returns: 변환된 `Food` 객체
  ///   - `id`: `FoodInfo.id`
  ///   - `foodName`: 음식 이름
  ///   - `totalGram`: 음식 총 중량
  ///   - `carbohydrate`, `protein`, `fat`: `MacroNutrients` 값
  ///
  /// - Example:
  ///   ```swift
  ///   let info = FoodInfo(
  ///     id: UUID(),
  ///     name: "닭가슴살",
  ///     weight: 100,
  ///     macros: MacroNutrients(carbohydrate: 0, protein: 23, fat: 2)
  ///   )
  ///   let food = info.toFood()
  ///   print(food.foodName) // "닭가슴살"
  ///   ```
  func toFood() -> Food {
    return Food(
      id: id,
      foodName: name,
      totalGram: weight,
      carbohydrate: macros.carbohydrate,
      protein: macros.protein,
      fat: macros.fat
    )
  }
}
