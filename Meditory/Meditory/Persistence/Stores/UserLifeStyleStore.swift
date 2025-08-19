//
//  UserLifeStyleStore.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//


import Foundation
import SwiftData

final class UserLifeStyleStore {
  var currentUser: User?
  /// currentUser 기준 LifeStyle 가져오거나 생성
  @MainActor
  func fetchOrCreateLifestyle(context: ModelContext) -> UserLifeStyle? {
    guard let currentUser = currentUser else { return nil }

    let targetID = currentUser.persistentModelID

    // 해당 user와 연결된 LifeStyle 1개만 조회
    var descriptor = FetchDescriptor<UserLifeStyle>(
      predicate: #Predicate<UserLifeStyle> { ls in
        ls.user?.persistentModelID == targetID
      }
    )
    descriptor.fetchLimit = 1

    if let existingLifestyle = try? context.fetch(descriptor).first {
      return existingLifestyle
    }

    // 없으면 기본값으로 생성 (UUID 사용)
    let newLifestyle = UserLifeStyle(
      id: UUID(),
      user: currentUser,
      wakeTime: "07:00",
      sleepTime: "23:30",
      breakfast: nil,
      lunch: "12:30",
      dinner: "19:30"
    )
    context.insert(newLifestyle)
    try? context.save()
    return newLifestyle
  }

  /// 편의 저장 함수
  @MainActor
  func saveLifestyle(context: ModelContext) {
    try? context.save()
  }

  // MARK: - 문자열("HH:mm") 기반 일괄 업데이트
  @MainActor
  func setLifestyleTimes(
    _ lifestyle: UserLifeStyle,
    context: ModelContext,
    wakeTime: String? = nil,
    sleepTime: String? = nil,
    breakfast: String? = nil,
    lunch: String? = nil,
    dinner: String? = nil
  ) {
    if let value = wakeTime { lifestyle.wakeTime = value }
    if let value = sleepTime { lifestyle.sleepTime = value }

    if let value = breakfast { lifestyle.breakfast = value }
    if let value = lunch { lifestyle.lunch = value }
    if let value = dinner { lifestyle.dinner = value }

    try? context.save()
  }

  // MARK: - Date 기반 일괄 업데이트 (DatePicker용)
  @MainActor
  func setLifestyleTimesDate(
    _ lifestyle: UserLifeStyle,
    context: ModelContext,
    wakeTime: Date? = nil,
    sleepTime: Date? = nil,
    breakfast: Date? = nil,
    lunch: Date? = nil,
    dinner: Date? = nil,
  ) {
    if let date = wakeTime { lifestyle.wakeTime = date.toHHmmString()}
    if let date = sleepTime { lifestyle.sleepTime = date.toHHmmString() }

    if let date = breakfast { lifestyle.breakfast = date.toHHmmString() }
    if let date = lunch { lifestyle.lunch = date.toHHmmString() }
    if let date = dinner { lifestyle.dinner = date.toHHmmString() }

    try? context.save()
  }
}
