//
//  MealModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/12/25.
//

import Foundation

struct MealInfo: Identifiable, Macroable, Codable {
  // TODO: UUID 갖다 버리기
  var id = UUID()
  var name: String // 식단 이름 (ex: 아침, 점심, 저녁)
  var date: Date = Date() // 날짜
  
  var foods: [FoodInfo] // 식단에 포함된 음식
  
  var macros: MacroNutrients {
    foods.reduce(MacroNutrients(carbohydrate: 0,
                                protein: 0,
                                fat: 0)) { result, food in
      MacroNutrients(carbohydrate: result.carbohydrate + food.macros.carbohydrate,
                     protein: result.protein + food.macros.protein,
                     fat: result.fat + food.macros.fat)
    }
  }
}
