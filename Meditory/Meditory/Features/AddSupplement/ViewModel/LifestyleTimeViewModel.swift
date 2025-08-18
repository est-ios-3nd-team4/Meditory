//
//  LifestyleTimeViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation

final class LifestyleTimeViewModel {
  var wakeUpTime = Date.makeTime(hour: 7)
  var bedTime = Date.makeTime(hour: 11)
  
  var dailyCycleTimes: [Date] {
    [wakeUpTime, bedTime]
  }
  
  var breakfastTime: Date? = Date.makeTime(hour: 8, minute: 30)
  var lunchTime: Date? = Date.makeTime(hour: 12, minute: 30)
  var dinnerTime: Date? = Date.makeTime(hour: 18, minute: 30)
  
  var mealTimes: [Date] {
    [
      breakfastTime ?? Date.makeTime(hour: 8, minute: 30),
     lunchTime ?? Date.makeTime(hour: 12, minute: 30),
     dinnerTime ?? Date.makeTime(hour: 18, minute: 30)
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
    case .wakeUp:
      return wakeUpTime.timeFormatter
    case .bedTime:
      return bedTime.timeFormatter
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
        case .wakeUp:
          self.wakeUpTime = $0.time
        case .bedTime:
          self.bedTime = $0.time
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
