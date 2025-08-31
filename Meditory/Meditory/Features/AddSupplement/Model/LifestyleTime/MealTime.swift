//
//  MealTime.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 식사 시간 정보를 나타내는 구조체
struct MealTime {
  /// 식사 종류 (아침/점심/저녁)
  let type: MealType
  /// 기록된 식사 시간
  let time: Date
  /// 실제로 식사했는지 여부
  let isEaten: Bool
}
