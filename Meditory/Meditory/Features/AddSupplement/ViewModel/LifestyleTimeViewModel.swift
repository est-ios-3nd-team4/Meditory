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
}
