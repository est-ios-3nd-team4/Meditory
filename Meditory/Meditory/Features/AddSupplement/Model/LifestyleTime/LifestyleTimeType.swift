//
//  LifestyleTimeType.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation

/// 생활 패턴 시간의 대분류 타입
enum LifestyleTimeType {
  /// 하루 주기 (기상/취침)
  case dailyCycle
  /// 식사 시간 (아침/점심/저녁)
  case meal
  
  var title: String {
    switch self {
    case .dailyCycle:
      return "기상·취침 시간"
    case .meal:
      return "식사 시간"
    }
  }
  
  var subtitle: String {
    switch self {
    case .dailyCycle:
      return "생활 패턴에 맞는 추천 섭취 시간을 알려드릴게요!"
    case .meal:
      return "식습관에 맞는 추천 섭취 시간을 알려드릴게요!"
    }
  }
}
