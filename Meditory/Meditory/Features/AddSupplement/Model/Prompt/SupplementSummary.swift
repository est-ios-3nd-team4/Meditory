//
//  SupplementSummary.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

struct SupplementSummary: Codable {
  let type: Int
  let name: String
  let description: String
  let category: String
  let usage: [String]
  let precautions: [String]
  
  var isUnidentifiable: Bool {
    self.type == 3
  }
}
