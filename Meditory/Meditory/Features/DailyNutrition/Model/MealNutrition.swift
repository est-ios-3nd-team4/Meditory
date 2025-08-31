//
//  MealNutrition.swift
//  Meditory
//
//  Created by 홍승아 on 8/27/25.
//

import Foundation

/// AI 모델이 반환하는 식사 영양소 정보 모델
struct MealNutrition: Codable {
  /// 추론 상태 (0 = 정상 추론, 1 = 알 수 없음)
  let type: Int
  let name: String
  let carbohydrate: Double
  let protein: Double
  let fat: Double
}

extension MealNutrition {
  func toFoodInfo() -> FoodInfo {
    FoodInfo(id: UUID(),
             name: name,
             weight: carbohydrate + protein + fat,
             macros: MacroNutrients(carbohydrate: carbohydrate,
                                    protein: protein,
                                    fat: fat))
  }
}
