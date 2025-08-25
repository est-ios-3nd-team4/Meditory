//
//  User+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/21/25.
//

import SwiftData
import Foundation

extension User {
  // 나이 계산
  var age: Int {
    let calendar = Calendar.current
    let now = Date()
    let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
    return ageComponents.year ?? 0
  }
  
  // 현재 키 (가장 최근 프로필에서)
  var currentHeight: Double? {
    currentProfile?.height
  }
  
  // 현재 몸무게
  var currentWeight: Double? {
    currentProfile?.weight
  }
  
  var debugDescription: String {
          """
          User: \(displayName)
          - Age: \(age)
          - Gender: \(gender)
          - Height: \(currentHeight ?? 0)cm
          - Weight: \(currentWeight ?? 0)kg
          - Profiles: \(userProfiles.count)개
          """
  }
}
