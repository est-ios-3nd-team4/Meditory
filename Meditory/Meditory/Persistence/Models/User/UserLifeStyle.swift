//
//  UserLifeStyle.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//


import SwiftData
import Foundation

@Model
final class UserLifeStyle {
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
