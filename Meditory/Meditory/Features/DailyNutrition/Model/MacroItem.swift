//
//  MacroModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import Foundation

// CoreModel
enum MacroType: String, Codable, CaseIterable {
  case carbohydrate
  case protein
  case fat
}

struct MacroItem: Identifiable {
  var id: String { type.rawValue }
  let type: MacroType
  let gram: Double
}
