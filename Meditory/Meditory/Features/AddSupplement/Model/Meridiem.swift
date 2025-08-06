//
//  Meridiem.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

enum Meridiem: Int, CaseIterable {
  case am
  case pm
  
  var title: String {
    switch self {
    case .am:
      return "오전"
    case .pm:
      return "오후"
    }
  }
}
