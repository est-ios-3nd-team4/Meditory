//
//  Meal+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

/// `Meal` 확장
/// - `Meal` 엔티티를 화면 표시용 또는 네트워크 전송용 DTO(`MealInfo`)로 변환하는 기능을 제공합니다.
/// - 데이터 저장 계층과 뷰/전달 계층 간의 분리를 돕고, 일관된 변환 로직을 유지합니다.
extension Meal {
  /// `Meal` → `MealInfo` 변환
  /// - Returns: 변환된 `MealInfo` 객체
  ///   - `id`: `Meal.id`
  ///   - `name`: 식사 이름 (`mealName`)
  ///   - `date`: 식사 날짜/시간
  ///   - `foods`: 포함된 음식 리스트를 `FoodInfo` 배열로 변환
  ///
  /// - Example:
  ///   ```swift
  ///   let meal = Meal(
  ///     id: UUID(),
  ///     mealName: "아침",
  ///     date: Date(),
  ///     foods: [Food(id: UUID(), foodName: "닭가슴살", totalGram: 100, carbohydrate: 0, protein: 23, fat: 2)]
  ///   )
  ///   let mealInfo = meal.toMealInfo()
  ///   print(mealInfo.name)  // "아침"
  ///   print(mealInfo.foods.first?.name ?? "")  // "닭가슴살"
  ///   ```
  func toMealInfo() -> MealInfo {
    return MealInfo(
      id: id,
      name: mealName,
      date: date,
      foods: foods.map { $0.toFoodInfo() }
    )
  }
}
