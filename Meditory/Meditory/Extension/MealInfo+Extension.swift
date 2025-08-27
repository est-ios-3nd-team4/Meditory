//
//  MealInfo+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/28/25.
//

import Foundation

extension MealInfo: Hashable {
  static func == (lhs: MealInfo, rhs: MealInfo) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension MealInfo {
  func toMeal() -> Meal {
    return Meal(id: id,
      mealName: name,
      date: date,
      foods: foods.map { $0.toFood() })
  }
}
