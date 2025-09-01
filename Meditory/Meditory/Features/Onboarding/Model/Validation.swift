//
//  Validation.swift
//  Meditory
//
//  Created by hyunsic on 8/13/25.
//

import SwiftUI

/// 필드의 유효성 검증에 사용되는 키
enum ValidationField: Hashable, CaseIterable {
  case name
  case birthDate
  case height
  case weight
}

/// 필드의 상태를 소유하는 속성
struct ValidationState {
  var content:String = ""
  var isValid: Bool = false
}

