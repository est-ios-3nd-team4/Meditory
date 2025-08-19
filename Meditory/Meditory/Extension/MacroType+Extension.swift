//
//  MacroType+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import SwiftUI

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
