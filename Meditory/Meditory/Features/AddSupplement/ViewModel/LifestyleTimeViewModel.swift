//
//  LifestyleTimeViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation
import SwiftData

final class LifestyleTimeViewModel {
  var wakeTime = Date.makeTime(hour: 7)
  var sleepTime = Date.makeTime(hour: 11)
  
  var dailyCycleTimes: [Date] {
    [wakeTime, sleepTime]
  }
  
  var breakfastTime: Date?
  var lunchTime: Date?
  var dinnerTime: Date?
  
  @MainActor
  init(context: ModelContext) {
    let lifestlyeStore = UserLifeStyleStore()
    // TODO: CurrentUser 초기화 필요
    // lifestlyeStore.currentUser
    if let lifestyle = lifestlyeStore.fetchOrCreateLifestyle(context: context) {
      self.wakeTime = lifestyle.wakeTimeDate
      self.sleepTime = lifestyle.sleepTimeDate
      self.breakfastTime = lifestyle.breakfastDate
      self.lunchTime = lifestyle.lunchDate
      self.dinnerTime = lifestyle.dinnerDate
    } else {
      // TODO: Test 코드 나중에 제거해야 함
      self.wakeTime = Date.makeTime(hour: 7)
      self.sleepTime = Date.makeTime(hour: 23)
      self.breakfastTime = Date.makeTime(hour: 8, minute: 30)
      self.lunchTime = Date.makeTime(hour: 12, minute: 00)
      self.dinnerTime = Date.makeTime(hour: 19, minute: 00)
    }
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
