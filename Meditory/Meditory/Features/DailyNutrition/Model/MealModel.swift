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
  
  var carbohydrate: Double // 탄수화물
  var protein: Double // 단백질
  var fat: Double // 지방
  
  var foods: [FoodModel] // 식단에 포함된 음식
}

extension MealModel {
  var carbohydrateModel: MacroModel {
    MacroModel(macroType: .carbohydrate,
               gram: carbohydrate)
  }
  var proteinModel: MacroModel {
    MacroModel(macroType: .protein,
               gram: protein)
  }
  var fatModel: MacroModel {
    MacroModel(macroType: .fat,
               gram: fat)
  }
}

struct FoodModel {
  var foodName: String // 음식 이름
  var totalGram: Double // 음식의 총 g 수
  
  var carbohydrate: Double // 탄수화물
  var protein: Double // 단백질
  var fat: Double // 지방
}

extension FoodModel {
  var carbohydrateModel: MacroModel {
    MacroModel(macroType: .carbohydrate,
               gram: carbohydrate)
  }
  var proteinModel: MacroModel {
    MacroModel(macroType: .protein,
               gram: protein)
  }
  var fatModel: MacroModel {
    MacroModel(macroType: .fat,
               gram: fat)
  }
}

