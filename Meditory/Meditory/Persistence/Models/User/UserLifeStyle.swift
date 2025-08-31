//
//  UserLifeStyle.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//

import SwiftData
import Foundation

/// 사용자의 생활 습관(수면, 식사 시간 등)을 관리하는 SwiftData 모델 클래스임.
///
/// 이 모델은 사용자의 기상, 취침 시간과 아침, 점심, 저녁 식사 시간을 문자열 형태로 저장하고,
/// `User` 모델과 역관계를 통해 연결됨.
@Model
final class UserLifeStyle: Sendable {
  /// 생활 습관 객체의 고유 식별자임.
  @Attribute(.unique) var id: UUID
  
  /// 이 생활 습관 정보와 연관된 `User` 객체임.
  @Relationship(inverse: \User.userLifeStyle) var user: User?
  
  // MARK: - 시간 정보 (문자열)
  
  /// 사용자의 기상 시간 (HH:mm 형식의 문자열).
  var wakeTime: String
  
  /// 사용자의 취침 시간 (HH:mm 형식의 문자열).
  var sleepTime: String
  
  /// 사용자의 아침 식사 시간 (HH:mm 형식의 문자열). 식사를 거를 경우 nil이 될 수 있음.
  var breakfast: String?
  
  /// 사용자의 점심 식사 시간 (HH:mm 형식의 문자열). 식사를 거를 경우 nil이 될 수 있음.
  var lunch: String?
  
  /// 사용자의 저녁 식사 시간 (HH:mm 형식의 문자열). 식사를 거를 경우 nil이 될 수 있음.
  var dinner: String?
  
  /// 새로운 `UserLifeStyle` 인스턴스를 생성하고 초기화함.
  /// - Parameters:
  ///   - id: 고유 UUID. 기본값으로 새로운 UUID가 생성됨.
  ///   - user: 연관된 `User` 객체.
  ///   - wakeTime: 기상 시간.
  ///   - sleepTime: 취침 시간.
  ///   - breakfast: 아침 식사 시간.
  ///   - lunch: 점심 식사 시간.
  ///   - dinner: 저녁 식사 시간.
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

// MARK: - 시간 변환 (Date)

extension UserLifeStyle {
  /// `wakeTime` 문자열을 `Date` 객체로 변환하여 반환함.
  var wakeTimeDate: Date {
    wakeTime.toDateFromHHmm() ?? Date.makeTime(hour: 7)
  }
  
  /// `sleepTime` 문자열을 `Date` 객체로 변환하여 반환함.
  var sleepTimeDate: Date {
    sleepTime.toDateFromHHmm() ?? Date.makeTime(hour: 23, minute: 30)
  }
  
  /// `breakfast` 문자열을 `Date` 객체로 변환하여 반환함. 시간이 설정되지 않은 경우 nil을 반환함.
  var breakfastDate: Date? {
    breakfast?.toDateFromHHmm()
  }
  
  /// `lunch` 문자열을 `Date` 객체로 변환하여 반환함. 시간이 설정되지 않은 경우 nil을 반환함.
  var lunchDate: Date? {
    lunch?.toDateFromHHmm()
  }
  
  /// `dinner` 문자열을 `Date` 객체로 변환하여 반환함. 시간이 설정되지 않은 경우 nil을 반환함.
  var dinnerDate: Date? {
    dinner?.toDateFromHHmm()
  }
}
