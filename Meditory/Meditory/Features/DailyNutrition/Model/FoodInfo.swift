//
//  FoodModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/13/25.
//

import Foundation

struct FoodInfo: Identifiable, Codable {
  // TODO: UUID 갖다 버리기
  var id = UUID()
  var name: String // 음식 이름
  var weight: Double // 음식의 총 g 수
  var macros: MacroNutrients
}
