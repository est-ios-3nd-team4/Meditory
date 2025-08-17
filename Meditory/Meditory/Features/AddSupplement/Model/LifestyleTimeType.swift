//
//  LifestyleTimeType.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation

enum LifestyleTimeType {
  case dailyCycle
  case meal
  
  var title: String {
    switch self {
    case .dailyCycle:
      return "기상·취침 시간"
    case .meal:
      return "식사 시간"
    }
  }
}
