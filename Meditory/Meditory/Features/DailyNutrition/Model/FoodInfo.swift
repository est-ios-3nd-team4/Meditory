//
//  FoodModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/13/25.
//

import Foundation

struct FoodInfo: Identifiable, Codable {
  var id: UUID
  var name: String // 음식 이름
  var weight: Double // 음식의 총 g 수
  var macros: MacroNutrients
}

extension FoodInfo: Hashable {
  static func == (lhs: FoodInfo, rhs: FoodInfo) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
