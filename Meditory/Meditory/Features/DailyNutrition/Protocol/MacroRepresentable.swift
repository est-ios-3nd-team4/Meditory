//
//  MacroItemService.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import Foundation

// MacroItemService vs Macroable vs MacroProtocol
protocol MacroRepresentable {
  var macros: MacroNutrients { get }
}

extension MacroRepresentable {
  var macroItems: [MacroItem] {
    MacroType.allCases.map { type in
      MacroItem(type: type,
                gram: macros[type])
    }
  }
}
