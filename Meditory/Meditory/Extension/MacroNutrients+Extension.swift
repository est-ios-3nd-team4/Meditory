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
