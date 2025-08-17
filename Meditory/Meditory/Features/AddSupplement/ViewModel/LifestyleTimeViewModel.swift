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
  
  var breakfastTime = Date.makeTime(hour: 8, minute: 30)
  var lunchTime = Date.makeTime(hour: 12, minute: 30)
  var dinnerTime = Date.makeTime(hour: 18, minute: 30)
  
  func time(for type: MealType) -> String {
    switch type {
    case .breakfast:
      return breakfastTime.timeFormatter
    case .lunch:
      return lunchTime.timeFormatter
    case .dinner:
      return dinnerTime.timeFormatter
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
