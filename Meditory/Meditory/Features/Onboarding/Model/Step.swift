//
//  Step.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//


/// 뷰를 단계적으로 표현하기 위한 스텝
enum Step: Int, CaseIterable {
  case privacyAgree
  case base
  case gender
  case allergy
  case disease
  case concern
  
  /// 모든 스텝의 갯수를 리턴
  static var totalCount: Int {
    return Self.allCases.count
  }

  /// 다음 스탭으로 진행
  func next() -> Step? {
    guard let index = Self.allCases.firstIndex(of: self),
      index < Self.allCases.count - 1
    else { return nil }
    return Self.allCases[index + 1]
  }

  /// 이전 스탭으로 복귀
  func previous() -> Step? {
    guard let index = Self.allCases.firstIndex(of: self),
      index > 0
    else { return nil }
    return Self.allCases[index - 1]
  }
}
