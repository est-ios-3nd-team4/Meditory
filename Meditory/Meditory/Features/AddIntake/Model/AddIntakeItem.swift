//
//  AddIntakeItem.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import UIKit

/// 복용 항목(영양제/식단) 추가 타입
enum AddIntakeItem: String, CaseIterable {
  /// 복용 약 추가
  case supplement
  /// 식단 추가
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
