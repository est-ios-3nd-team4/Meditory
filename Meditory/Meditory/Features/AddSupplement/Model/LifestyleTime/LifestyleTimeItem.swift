//
//  LifestyleTimeItem.swift
//  Meditory
//
//  Created by 홍승아 on 8/25/25.
//

import Foundation

/// 하나의 생활 패턴 시간 정보를 나타내는 모델
struct LifestyleTimeItem {
  /// 생활 패턴 타입 (기상/취침, 아침/점심/저녁 등)
  let type: any LifestyleTime
  /// 해당 생활 패턴의 시간 (문자열)
  let time: String
}
