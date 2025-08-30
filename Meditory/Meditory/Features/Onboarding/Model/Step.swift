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
  case privacyAgree
  
  static var totalCount: Int {
    return Self.allCases.count
  }

  func next() -> Step? {
    guard let index = Self.allCases.firstIndex(of: self),
      index < Self.allCases.count - 1
    else { return nil }
    return Self.allCases[index + 1]
  }

  func previous() -> Step? {
    guard let index = Self.allCases.firstIndex(of: self),
      index > 0
    else { return nil }
    return Self.allCases[index - 1]
  }
}
