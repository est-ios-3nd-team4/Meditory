//
//  DailyCycleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

/// 사용자의 하루 주기 시간 타입 정의 (기상 / 취침)
enum DailyCycleType: String, LifestyleTime {
  /// 기상 시간
  case wakeTime
  /// 취침 시간
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
