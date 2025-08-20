//
//  NutritionCalculator.swift
//  Meditory
//
//  Created by 이치훈 on 8/20/25.
//

import Foundation

struct NutritionCalculator {
  
  /// 기초대사율 계산 (BMR)
  static func calculateBMR(weight: Double, height: Double, age: Int, isMale: Bool) -> Double {
    if isMale { // 남자 BMR 계산
      return (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
    } else { // 여자 BMR 계산
      return (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
    }
  }
  
  /// 일일 권장 칼로리 계산
  static func calculateDailyCalories(bmr: Double, activityLevel: ActivityLevel) -> Double {
    return bmr * activityLevel.activityFactor
  }
  
  static func calculateMacros(dailyCalories: Double) -> MacroNutrients {
    let carbCalories = dailyCalories * 0.5
    let proteinCalories = dailyCalories * 0.3
    let fatCalories = dailyCalories * 0.2
    
    return MacroNutrients(carbohydrate: carbCalories / 4,
                          protein: proteinCalories / 4,
                          fat: fatCalories / 9)
  }
  
}
