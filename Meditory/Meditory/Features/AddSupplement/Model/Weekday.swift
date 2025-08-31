//
//  Weekday.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

/// 요일을 나타내는 열거형.
enum Weekday: Int, CaseIterable {
  case sun
  case mon
  case tue
  case wed
  case thu
  case fri
  case sat
  
  var title: String {
    switch self {
    case .mon:
      return "월요일"
    case .tue:
      return "화요일"
    case .wed:
      return "수요일"
    case .thu:
      return "목요일"
    case .fri:
      return "금요일"
    case .sat:
      return "토요일"
    case .sun:
      return "일요일"
    }
  }
  
  /// 요일의 축약 이름 (예: `"월"`)
  var subTitle: String {
    title.first.map(String.init) ?? ""
  }
}
