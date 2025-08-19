//
//  NutritionMainViewModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/18/25.
//

import SwiftUI

@MainActor
class NutritionMainViewModel: ObservableObject {
  
  // MARK: - Published Properties
  /// meals: swiftDat에서 meal 데이터를 불러 올 때 selectredDate를 기반으로 filter해서 불러옴
  @Published var meals: [MealInfo] = []
  @Published var selectedDate = Date()
  @Published var selectedMeal: MealInfo? = nil
  
  // TODO: SwiftData 쿼리문으로 처리 예정
//  var todayMeals: [MealInfo] {
//    meals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectredDate) }
//  }
  
  /// 오늘 하루 Macro의 총 합을 제공하는 연산 프로퍼티
  var todayTotalMacros: MacroNutrients {
    meals.reduce(MacroNutrients(carbohydrate: 0,
                                protein: 0,
                                fat: 0)) { result, macro in
      MacroNutrients(carbohydrate: result.carbohydrate + macro.macros.carbohydrate,
                     protein: result.protein + macro.macros.protein,
                     fat: result.fat + macro.macros.fat)
    }
  }
  
  func selectedMeal(_ meal: MealInfo) {
    self.selectedMeal = meal
  }
  
  func deSelectedMeal() {
    self.selectedMeal = nil
  }

}
