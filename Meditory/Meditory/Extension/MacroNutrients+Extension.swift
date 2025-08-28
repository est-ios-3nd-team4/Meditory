//
//  MacroNutrients.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

extension MacroNutrients {
  var macroItems: [MacroItem] {
    MacroType.allCases.map { type in
      MacroItem(type: type,
                gram: self[type])
    }
  }
}

extension MacroNutrients: Equatable {
  static func == (lhs: MacroNutrients, rhs: MacroNutrients) -> Bool {
    return lhs.carbohydrate == rhs.carbohydrate &&
    lhs.protein == rhs.protein &&
    lhs.fat == rhs.fat
  }
}
