//
//  MealInfo+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/28/25.
//

import Foundation

/// `MealInfo` 확장
/// - `Hashable` 채택을 통해 식사 정보를 컬렉션(Set, Dictionary 등)에서 효율적으로 관리할 수 있습니다.
/// - 또한 `MealInfo`를 저장/도메인 모델인 `Meal`로 변환하는 기능을 제공합니다.
extension MealInfo: Hashable {
  /// 두 `MealInfo` 객체가 동일한지 비교합니다.
  /// - 기준: `id` 값이 동일하면 같은 객체로 간주합니다.
  static func == (lhs: MealInfo, rhs: MealInfo) -> Bool {
    lhs.id == rhs.id
  }
  
  /// `Hashable` 프로토콜 구현
  /// - `id`를 해시 값으로 사용합니다.
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension MealInfo {
  /// `MealInfo` → `Meal` 변환
  /// - Returns: 변환된 `Meal` 객체
  ///   - `id`: 동일한 UUID
  ///   - `mealName`: 이름
  ///   - `date`: 날짜
  ///   - `foods`: `FoodInfo` 배열을 `Food` 배열로 변환
  ///
  /// - Example:
  ///   ```swift
  ///   let mealInfo = MealInfo(
  ///     id: UUID(),
  ///     name: "점심",
  ///     date: Date(),
  ///     foods: [FoodInfo(id: UUID(), name: "현미밥", weight: 200, macros: MacroNutrients(carbohydrate: 45, protein: 5, fat: 2))]
  ///   )
  ///   let meal = mealInfo.toMeal()
  ///   print(meal.mealName)  // "점심"
  ///   ```
  func toMeal() -> Meal {
    return Meal(
      id: id,
      mealName: name,
      date: date,
      foods: foods.map { $0.toFood() }
    )
  }
}
