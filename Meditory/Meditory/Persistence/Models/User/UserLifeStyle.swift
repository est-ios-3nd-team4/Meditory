//
//  UserLifeStyle.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//


import SwiftData
import Foundation

@Model
final class UserLifeStyle: @unchecked Sendable {
  @Attribute(.unique) var id: UUID
  @Relationship(inverse: \User.userLifeStyle) var user: User?
  
  // 수면/기상
  var wakeTimeWeekday: String
  var sleepTimeWeekday: String
  var wakeTimeWeekend: String?
  var sleepTimeWeekend: String?
  
  // 식사(평일/주말)
  var breakfastWeekday: String?
  var lunchWeekday: String?
  var dinnerWeekday: String?
  var breakfastWeekend: String?
  var lunchWeekend: String?
  var dinnerWeekend: String?
  
  init(
    id: UUID = UUID(),
    user: User? = nil,
    wakeTimeWeekday: String = "07:00",
    sleepTimeWeekday: String = "23:30",
    wakeTimeWeekend: String? = nil,
    sleepTimeWeekend: String? = nil,
    breakfastWeekday: String? = nil,
    lunchWeekday: String? = "12:00",
    dinnerWeekday: String? = "19:00",
    breakfastWeekend: String? = nil,
    lunchWeekend: String? = "12:30",
    dinnerWeekend: String? = "19:30"
  ) {
    self.id = id
    self.user = user
    self.wakeTimeWeekday = wakeTimeWeekday
    self.sleepTimeWeekday = sleepTimeWeekday
    self.wakeTimeWeekend = wakeTimeWeekend
    self.sleepTimeWeekend = sleepTimeWeekend
    self.breakfastWeekday = breakfastWeekday
    self.lunchWeekday = lunchWeekday
    self.dinnerWeekday = dinnerWeekday
    self.breakfastWeekend = breakfastWeekend
    self.lunchWeekend = lunchWeekend
    self.dinnerWeekend = dinnerWeekend
  }
}
