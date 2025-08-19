//
//  Validation.swift
//  Meditory
//
//  Created by hyunsic on 8/13/25.
//

import SwiftUI

enum ValidationField: Hashable, CaseIterable {
  case name
  case birthDate
  case height
  case weight
}

struct ValidationState {
  var content:String = ""
  var isValid: Bool = false
}

