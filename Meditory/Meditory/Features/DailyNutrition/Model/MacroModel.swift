//
//  MacroModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

enum MacroType: String {
  case carbohydrate = "carbohydrate"
  case protein = "protein"
  case fat = "fat"
  
  var info: (name: String, color: Color) {
    switch self {
    case .carbohydrate:
      return ("탄", .customCarbohydrate)
    case .protein:
      return ("단", .customProtein)
    case .fat:
      return ("지", .customFat)
    }
  }
}

struct MacroModel: Identifiable {
  var id: String { macroType.rawValue }
  let macroType: MacroType
  let gram: Double
  var label: String { macroType.info.name }
  var color: Color { macroType.info.color }
}
