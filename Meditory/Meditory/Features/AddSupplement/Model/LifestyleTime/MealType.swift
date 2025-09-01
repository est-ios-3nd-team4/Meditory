//
//  MealType.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import Foundation

/// 식사 시간 유형을 나타내는 열거형
enum MealType: String, LifestyleTime {
  case breakfast
  case lunch
  case dinner
  
  var title: String {
    switch self {
    case .breakfast:
      return "아침 시간"
    case .lunch:
      return "점심 시간"
    case .dinner:
      return "저녁 시간"
    }
  }
  
  var imageName: String {
    "icon_\(self.rawValue)"
  }
}
