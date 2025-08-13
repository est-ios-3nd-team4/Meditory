//
//  MealModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/12/25.
//

import Foundation

struct MealModel: Identifiable {
  var id = UUID()
  var mealName: String // 식단 이름 (ex: 아침, 점심, 저녁)
  var date: Date // 날짜
  
  var carbohydrate: Double
  var protein: Double
  var fat: Double
  
  var foods: [FoodModel] // 식단에 포함된 음식
}

extension MealModel {
  // MacroModel로 변환하는 작업이 가독성을 해치지 않을까?
  var carbohydrateModel: MacroModel {
    MacroModel(macro: .carbohydrate,
               gram: carbohydrate)
  }
  var proteinModel: MacroModel {
    MacroModel(macro: .protein,
               gram: protein)
  }
  var fatModel: MacroModel {
    MacroModel(macro: .fat,
               gram: fat)
  }
}

struct FoodModel {
  var foodName: String // 음식 이름
  var totalGram: Double // 음식의 총 g 수
  var macros: [MacroModel] // 음식의 탄, 단, 지 g
}
