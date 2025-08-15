//
//  FoodModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/13/25.
//

import Foundation

struct FoodInfo: Identifiable, Codable {
  var id = UUID()
  var name: String // 음식 이름
  var weight: Double // 음식의 총 g 수
  var macros: MacroNutrients
  
  var macroItems: [MacroItem] {
    MacroType.allCases.map { type in
      MacroItem(type: type,
                gram: macros[type])
    }
  }

}

struct MacroNutrients: Codable {
  var carbohydrate: Double // 탄수화물
  var protein: Double // 단백질
  var fat: Double // 지방
  
  subscript(type: MacroType) -> Double {
    get {
      switch type {
      case .carbohydrate: return carbohydrate
      case .protein: return protein
      case .fat: return fat
      }
    }
    set {
      switch type {
      case .carbohydrate: carbohydrate = newValue
      case .protein: protein = newValue
      case .fat: fat = newValue
      }
    }
  }
}
