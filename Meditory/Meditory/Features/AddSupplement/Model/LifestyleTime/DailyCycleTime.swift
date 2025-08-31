//
//  DailyCycleTime.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 사용자의 하루 주기 시간(기상, 취침)을 표현하는 모델
struct DailyCycleTime {
  /// 하루 주기 타입 (예: 기상, 취침)
  let type: DailyCycleType
  /// 해당 주기 시간
  let time: Date
}
