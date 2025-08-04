//
//  Step.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

enum Step: Int, CaseIterable {
  case name
  case age
  case height
  case weight
  case gender
  case end

  var index: Int {
    return Self.allCases.firstIndex(of: self)!
  }

  static var totalCount: Int {
    return Self.allCases.count
  }

  func next() -> Step? {
    let all = Self.allCases
    let idx = index + 1
    return idx < all.count ? all[idx] : nil
  }

  func previous() -> Step? {
    let idx = index - 1
    return idx >= 0 ? Self.allCases[idx] : nil
  }
}
