//
//  Weekday.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

enum Weekday: Int, CaseIterable {
  case mon
  case tue
  case wed
  case thu
  case fri
  case sat
  case sun
  
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
  
  var subTitle: String {
    title.first.map(String.init) ?? ""
  }
}
