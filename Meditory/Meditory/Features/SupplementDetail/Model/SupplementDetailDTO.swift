//
//  SupplementDetailDTO.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation

struct SupplementDetailDTO: Equatable {
  let name: String
  let subtitle: String
  let userTimes: [String]
  let userCycle: String
  let recTimes: [String]
  let recCycle: String
}
