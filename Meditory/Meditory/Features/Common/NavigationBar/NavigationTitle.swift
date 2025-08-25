//
//  NavigationTitle.swift
//  Meditory
//
//  Created by 홍승아 on 8/23/25.
//

import Foundation

enum NavigationTitle {
  case addSupplement
  case supplementDetail
  case mealDetail
  case aiAnalysisResult
  case custom(String)
  case none
  
  var text: String {
    switch self {
    case .addSupplement: return "복용 약 추가"
    case .supplementDetail: return "복용 약 정보"
    case .mealDetail: return "식단 상세 정보"
    case .aiAnalysisResult: return "AI분석 전체 결과"
    case .custom(let title): return title
    case .none: return ""
    }
  }
}
