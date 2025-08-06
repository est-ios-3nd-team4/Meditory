//
//  TabItem.swift
//  Meditory
//
//  Created by 홍승아 on 8/4/25.
//

import SwiftUI

enum TabItem: CaseIterable {
  case home
  case recommend
  case add
  case dailyNutrition
  case settings
  
  var isHome: Bool {
    self == .home
  }
  
  var isAdd: Bool {
    self == .add
  }
  
  var title: String {
    switch self {
    case .home: return "홈"
    case .recommend: return "영양제"
    case .add: return ""
    case .dailyNutrition: return "식단"
    case .settings: return "설정"
    }
  }
  
  var iconImage: String {
    switch self {
    case .home: return "icon_home"
    case .recommend: return "pill.fill"
    case .add: return "plus"
    case .dailyNutrition: return "fork.knife"
    case .settings: return "gearshape.fill"
    }
  }
}
