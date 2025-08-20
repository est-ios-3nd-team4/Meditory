//
//  DailyCycleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

enum DailyCycleType: String, LifestyleTime {
  case wakeTime
  case sleepTime
  
  var title: String {
    switch self {
    case .wakeTime:
      return "기상 시간"
    case .sleepTime:
      return "취침 시간"
    }
  }
  
  var imageName: String {
    "icon_\(self.rawValue)"
  }
}
