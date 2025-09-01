//
//  User+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/21/25.
//

import SwiftData
import Foundation

/// `User` 모델 확장
///
/// 사용자 객체(`User`)에 나이 계산, 현재 신체 정보 접근,
/// 그리고 디버깅에 유용한 설명 문자열을 제공합니다.
extension User {
  /// 사용자의 만 나이 계산
  ///
  /// - 현재 날짜(`Date()`)를 기준으로 `birthDate`로부터의 연도를 계산합니다.
  /// - 생일이 미래일 경우 0으로 처리됩니다.
  var age: Int {
    let calendar = Calendar.current
    let now = Date()
    let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
    return ageComponents.year ?? 0
  }
  
  /// 사용자의 현재 키(cm)
  ///
  /// - 가장 최근 프로필(`currentProfile`)에 저장된 값을 반환합니다.
  /// - 값이 없을 경우 `nil`을 반환합니다.
  var currentHeight: Double? {
    currentProfile?.height
  }
  
  /// 사용자의 현재 몸무게(kg)
  ///
  /// - 가장 최근 프로필(`currentProfile`)에 저장된 값을 반환합니다.
  /// - 값이 없을 경우 `nil`을 반환합니다.
  var currentWeight: Double? {
    currentProfile?.weight
  }
  
  /// 사용자 객체의 디버그용 설명 문자열
  ///
  /// - `displayName`, 나이, 성별, 현재 키/몸무게, 프로필 개수를 보기 좋게 출력합니다.
  ///
  /// - Example:
  ///   ```
  ///   User: 홍길동
  ///   - Age: 25
  ///   - Gender: Male
  ///   - Height: 175.0cm
  ///   - Weight: 70.0kg
  ///   - Profiles: 3개
  ///   ```
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
