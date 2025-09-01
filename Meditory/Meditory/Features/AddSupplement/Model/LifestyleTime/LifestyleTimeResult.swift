//
//  LifestyleTimeResult.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 생활 패턴 시간 선택 결과를 나타내는 열거형
enum LifestyleTimeResult {
  /// 기상/취침 시간 등 하루 주기 결과
  case dailyCycle([DailyCycleTime])
  /// 식사 시간 결과
  case meal([MealTime])
}
