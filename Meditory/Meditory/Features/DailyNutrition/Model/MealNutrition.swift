//
//  MealNutrition.swift
//  Meditory
//
//  Created by 홍승아 on 8/27/25.
//

import Foundation

struct MealNutrition: Codable {
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
