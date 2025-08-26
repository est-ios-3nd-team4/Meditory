//
//  UserLifeStyle.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//


import SwiftData
import Foundation

@Model
final class UserLifeStyle: Sendable {
  @Attribute(.unique) var id: UUID
  @Relationship(inverse: \User.userLifeStyle) var user: User?
  
  // 수면/기상
  var wakeTime: String
  var sleepTime: String

  // 식사
  var breakfast: String?
  var lunch: String?
  var dinner: String?
  
  init(
    id: UUID = UUID(),
    user: User? = nil,
    wakeTime: String = "07:00",
    sleepTime: String = "23:30",
    breakfast: String? = nil,
    lunch: String? = "12:00",
    dinner: String? = "19:00"
  ) {
    self.id = id
    self.user = user
    self.wakeTime = wakeTime
    self.sleepTime = sleepTime
    self.breakfast = breakfast
    self.lunch = lunch
    self.dinner = dinner
  }
}


extension UserLifeStyle {
  var wakeTimeDate: Date {
    wakeTime.toDateFromHHmm() ?? Date.makeTime(hour: 7)
  }
  var sleepTimeDate: Date {
    sleepTime.toDateFromHHmm() ?? Date.makeTime(hour: 23, minute: 30)
  }
  var breakfastDate: Date? {
    breakfast?.toDateFromHHmm()
  }
  var lunchDate: Date? {
    lunch?.toDateFromHHmm()
  }
  var dinnerDate: Date? {
    dinner?.toDateFromHHmm()
  }
  static var standard: UserLifeStyle {
    UserLifeStyle(
      wakeTime: "07:00",
      sleepTime: "23:30",
      breakfast: "08:30",
      lunch: "12:00",
      dinner: "19:00"
    )
  }
}


extension UserLifeStyle: Equatable {
  static func == (lhs: UserLifeStyle, rhs: UserLifeStyle) -> Bool {
    return lhs.id == rhs.id &&
    lhs.wakeTime == rhs.wakeTime &&
    lhs.sleepTime == rhs.sleepTime &&
    lhs.breakfast == rhs.breakfast &&
    lhs.lunch == rhs.lunch &&
    lhs.dinner == rhs.dinner
  }
}
