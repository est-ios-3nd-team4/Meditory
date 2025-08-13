//
//  MacroModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

enum Macro: String {
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
  var id: String { macro.rawValue }
  let macro: Macro
  let gram: Double
  var label: String { macro.info.name }
  var color: Color { macro.info.color }
}
