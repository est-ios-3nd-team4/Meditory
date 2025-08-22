//
//  LifestyleTimeViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation
import SwiftData

@Observable
class LifestyleTimeViewModel {
  var wakeTime = Date.makeTime(hour: 7)
  var sleepTime = Date.makeTime(hour: 11)
  
  var breakfastTime: Date?
  var lunchTime: Date?
  var dinnerTime: Date?
  
  // MARK: - @ModelActor 대응용
  private var lifestyleID: PersistentIdentifier?
  private let lifestyleStore: UserLifeStyleStore
  
  
  // MARK: - Computed Properties
  var dailyCycleTimes: [Date] {
    [wakeTime, sleepTime]
  }
  
  var userlifeStyle: UserLifeStyle {
    UserLifeStyle(
      wakeTime: wakeTime.toHHmmString(),
      sleepTime: sleepTime.toHHmmString(),
      breakfast: breakfastTime?.toHHmmString(),
      lunch: lunchTime?.toHHmmString(),
      dinner: dinnerTime?.toHHmmString()
    )
  }
  
  var mealTimes: [Date] {
    [
      breakfastTime ?? Date.makeTime(hour: 8, minute: 30),
      lunchTime ?? Date.makeTime(hour: 12, minute: 00),
      dinnerTime ?? Date.makeTime(hour: 19, minute: 00)
    ]
  }
  
  var mealSelections: [Bool] {
    [
      breakfastTime != nil,
      lunchTime != nil,
      dinnerTime != nil
    ]
  }
  
  // MARK: - 생성자
  init(lifestyleStore: UserLifeStyleStore) {
    self.lifestyleStore = lifestyleStore
    
    // 기본 초기값 설정
    self.wakeTime = Date.makeTime(hour: 7)
    self.sleepTime = Date.makeTime(hour: 23, minute: 30)
    self.breakfastTime = nil
    self.lunchTime = Date.makeTime(hour: 12, minute: 30)
    self.dinnerTime = Date.makeTime(hour: 19, minute: 30)
  }
  
  // MARK: - @ModelActor 통신용 메서드
  
  /// DB에서 데이터를 비동기적으로 불러와 ViewModel의 상태를 업데이트합니다.
  @MainActor
  func loadLifestyle(for user: User, context: ModelContext) async {
    // 1. Store와 통신하려면 현재 User의 ID가 필요합니다.
    let userID = user.persistentModelID
    
    // 2. Store에 ID를 주고, LifeStyle 데이터의 ID를 받아옵니다.
    guard let id = await lifestyleStore.fetchOrCreateLifestyleID(for: userID) else { return }
    self.lifestyleID = id // 나중에 저장할 때 쓰기 위해 ID를 보관합니다.
    
    // 3. 받아온 ID를 사용해 현재 View의 context에서 실제 객체를 찾습니다.
    if let lifestyle = context.model(for: id) as? UserLifeStyle {
      // 4. 찾은 객체의 데이터로 ViewModel의 프로퍼티들을 업데이트합니다.
      self.wakeTime = lifestyle.wakeTimeDate
      self.sleepTime = lifestyle.sleepTimeDate
      self.breakfastTime = lifestyle.breakfastDate
      self.lunchTime = lifestyle.lunchDate
      self.dinnerTime = lifestyle.dinnerDate
    }
  }
  
  /// ViewModel의 현재 상태를 DB에 비동기적으로 저장합니다.
  @MainActor
  func saveChanges() async {
    // 1. 저장해 둔 LifeStyle 데이터의 ID를 가져옵니다.
    guard let lifestyleID = self.lifestyleID else { return }
    
    // 2. Store에 ID와 변경된 시간 값들을 전달하여 저장을 요청합니다.
    await lifestyleStore.setLifestyleTimesDate(
      id: lifestyleID,
      wakeTime: self.wakeTime,
      sleepTime: self.sleepTime,
      breakfast: self.breakfastTime,
      lunch: self.lunchTime,
      dinner: self.dinnerTime
    )
  }
  
  // MARK: - 일반 함수들
  
  func time(for type: MealType) -> String {
    switch type {
    case .breakfast:
      return breakfastTime?.timeFormatter ?? "식사 안 함"
    case .lunch:
      return lunchTime?.timeFormatter ?? "식사 안 함"
    case .dinner:
      return dinnerTime?.timeFormatter ?? "식사 안 함"
    }
  }
  
  func time(for type: DailyCycleType) -> String {
    switch type {
    case .wakeTime:
      return wakeTime.timeFormatter
    case .sleepTime:
      return sleepTime.timeFormatter
    }
  }
  
  func times(for type: LifestyleTimeType) -> [Date] {
    switch type {
    case .dailyCycle:
      return dailyCycleTimes
    case .meal:
      return mealTimes
    }
  }
  
  func mealSelections(for type: LifestyleTimeType) -> [Bool] {
    switch type {
    case .dailyCycle:
      return DailyCycleType.allCases.map { _ in return true }
    case .meal:
      return mealSelections
    }
  }
  
  func setTime(_ result: LifestyleTimeResult) {
    switch result {
    case .dailyCycle(let dailyCycleTimes):
      dailyCycleTimes.forEach {
        switch $0.type {
        case .wakeTime:
          self.wakeTime = $0.time
        case .sleepTime:
          self.sleepTime = $0.time
        }
      }
    case .meal(let mealTimes):
      mealTimes.forEach {
        switch $0.type {
        case .breakfast:
          self.breakfastTime = $0.isEaten ? $0.time : nil
        case .lunch:
          self.lunchTime = $0.isEaten ? $0.time : nil
        case .dinner:
          self.dinnerTime = $0.isEaten ? $0.time : nil
        }
      }
    }
  }
}
