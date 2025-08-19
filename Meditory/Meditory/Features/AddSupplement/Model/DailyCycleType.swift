//
//  DailyCycleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

enum DailyCycleType: String, LifestyleTime {
  case wakeUp
  case bedTime
  
  var title: String {
    switch self {
    case .wakeUp:
      return "기상 시간"
    case .bedTime:
      return "취침 시간"
    }
  }
  
  var imageName: String {
    "icon_\(self.rawValue)"
  }
}
