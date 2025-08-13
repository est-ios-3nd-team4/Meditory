//
//  SupplementScheduleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation

enum SupplementScheduleType: Int, CaseIterable {
  case weekday = 1
  case interval
  
  var title: String {
    switch self {
    case .weekday:
      return "요일별"
    case .interval:
      return "주기별"
    }
  }
}
