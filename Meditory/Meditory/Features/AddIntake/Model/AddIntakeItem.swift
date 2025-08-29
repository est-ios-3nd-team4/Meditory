//
//  AddIntakeItem.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import UIKit

enum AddIntakeItem: String, CaseIterable {
  case supplement
  case meal
  
  var imageName: String {
    "icon_\(self.rawValue)"
  }
  
  var title: String {
    switch self {
    case .supplement:
      return UIDevice.isPad ? "복용 약\n추가" : "복용 약 추가"
    case .meal:
      return "식단 추가"
    }
  }
}
