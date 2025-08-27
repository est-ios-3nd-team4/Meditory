//
//  Meal+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

extension Meal {
  func toMealInfo() -> MealInfo {
    return MealInfo(id: id,
                    name: mealName,
                    date: date,
                    foods: foods.map { $0.toFoodInfo() })
  }
}
