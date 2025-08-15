//
//  MacroModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

enum MacroType: String, Codable, CaseIterable {
  case carbohydrate
  case protein
  case fat
}
 
extension MacroType {
  
  var displayName: String {
    switch self {
    case .carbohydrate: return "탄수화물"
    case .protein: return "단백질"
    case .fat: return "지방"
    }
  }
  
  var color: Color {
    switch self {
    case .carbohydrate: return .customCarbohydrate
    case .protein: return .customProtein
    case .fat: return .customFat
    }
  }
  
}

struct MacroItem: Identifiable {
  var id: String { type.rawValue }
  let type: MacroType
  let gram: Double
}

extension MacroItem {
  var label: String { type.displayName }
  var color: Color { type.color }
}
