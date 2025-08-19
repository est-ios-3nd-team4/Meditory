//
//  Step.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

enum Step: Int, CaseIterable {
  case base
  case gender
  case allergy
  case disease
  case concern
  
  static var totalCount: Int {
    return Self.allCases.count
  }

  func nextView() -> Step? {
    switch self {
      case .base: return .gender
      case .gender: return .allergy
      case .allergy: return .disease
      case .disease: return .concern
      case .concern: return nil
    }
  }
  
}



