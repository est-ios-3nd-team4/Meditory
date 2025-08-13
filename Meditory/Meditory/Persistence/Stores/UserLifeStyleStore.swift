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
      wakeTimeWeekday: "07:00",
      sleepTimeWeekday: "23:30",
      wakeTimeWeekend: nil,
      sleepTimeWeekend: nil,
      breakfastWeekday: nil,
      lunchWeekday: "12:00",
      dinnerWeekday: "19:00",
      breakfastWeekend: nil,
      lunchWeekend: "12:30",
      dinnerWeekend: "19:30"
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
    wakeWeekday: String? = nil,
    sleepWeekday: String? = nil,
    wakeWeekend: String? = nil,
    sleepWeekend: String? = nil,
    breakfastWeekday: String? = nil,
    lunchWeekday: String? = nil,
    dinnerWeekday: String? = nil,
    breakfastWeekend: String? = nil,
    lunchWeekend: String? = nil,
    dinnerWeekend: String? = nil
  ) {
    if let value = wakeWeekday { lifestyle.wakeTimeWeekday = value }
    if let value = sleepWeekday { lifestyle.sleepTimeWeekday = value }
    if let value = wakeWeekend  { lifestyle.wakeTimeWeekend  = value }
    if let value = sleepWeekend { lifestyle.sleepTimeWeekend = value }

    if let value = breakfastWeekday { lifestyle.breakfastWeekday = value }
    if let value = lunchWeekday     { lifestyle.lunchWeekday     = value }
    if let value = dinnerWeekday    { lifestyle.dinnerWeekday    = value }

    if let value = breakfastWeekend { lifestyle.breakfastWeekend = value }
    if let value = lunchWeekend     { lifestyle.lunchWeekend     = value }
    if let value = dinnerWeekend    { lifestyle.dinnerWeekend    = value }

    try? context.save()
  }

  // MARK: - Date 기반 일괄 업데이트 (DatePicker용)
  @MainActor
  func setLifestyleTimesDate(
    _ lifestyle: UserLifeStyle,
    context: ModelContext,
    wakeWeekday: Date? = nil,
    sleepWeekday: Date? = nil,
    wakeWeekend: Date? = nil,
    sleepWeekend: Date? = nil,
    breakfastWeekday: Date? = nil,
    lunchWeekday: Date? = nil,
    dinnerWeekday: Date? = nil,
    breakfastWeekend: Date? = nil,
    lunchWeekend: Date? = nil,
    dinnerWeekend: Date? = nil
  ) {
    if let date = wakeWeekday { lifestyle.wakeTimeWeekday = date.toHHmmString()}
    if let date = sleepWeekday { lifestyle.sleepTimeWeekday = date.toHHmmString() }
    if let date = wakeWeekend  { lifestyle.wakeTimeWeekend  = date.toHHmmString() }
    if let date = sleepWeekend { lifestyle.sleepTimeWeekend = date.toHHmmString() }

    if let date = breakfastWeekday { lifestyle.breakfastWeekday = date.toHHmmString() }
    if let date = lunchWeekday     { lifestyle.lunchWeekday     = date.toHHmmString() }
    if let date = dinnerWeekday    { lifestyle.dinnerWeekday    = date.toHHmmString() }

    if let date = breakfastWeekend { lifestyle.breakfastWeekend = date.toHHmmString() }
    if let date = lunchWeekend     { lifestyle.lunchWeekend     = date.toHHmmString() }
    if let date = dinnerWeekend    { lifestyle.dinnerWeekend    = date.toHHmmString() }

    try? context.save()
  }
}
