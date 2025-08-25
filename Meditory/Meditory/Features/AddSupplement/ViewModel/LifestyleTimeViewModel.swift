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
  var wakeTime: Date?
  var sleepTime: Date?
  
  var breakfastTime: Date?
  var lunchTime: Date?
  var dinnerTime: Date?
  
  private var lifestyleID: PersistentIdentifier?
  private let lifestyleStore: UserLifeStyleStore
  
  var dailyCycleTimes: [Date] {
    [
      wakeTime ?? Date.makeTime(hour: 7),
      sleepTime ?? Date.makeTime(hour: 23, minute: 30)
    ]
  }
  
  var userlifeStyle: UserLifeStyle? {
    guard let wakeTime, let sleepTime else { return nil }
    
    return UserLifeStyle(
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
  
  init(lifestyleStore: UserLifeStyleStore) {
    self.lifestyleStore = lifestyleStore
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
      return wakeTime?.timeFormatter ?? ""
    case .sleepTime:
      return sleepTime?.timeFormatter ?? ""
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
  
  func lifestyleTimeItems(for type: LifestyleTimeType) -> [LifestyleTimeItem] {
    switch type {
    case .dailyCycle:
      return DailyCycleType.allCases.map { type in
        LifestyleTimeItem(
          type: type,
          time: time(for: type),
        )
      }
    case .meal:
      return MealType.allCases.map { type in
        LifestyleTimeItem(
          type: type,
          time: time(for: type),
        )
      }
    }
  }
}


// MARK: - DB
extension LifestyleTimeViewModel {
  func loadLifestyle(for user: User, context: ModelContext) async {
    let userID = user.persistentModelID
    
    guard let id = await lifestyleStore.fetchOrCreateLifestyleID(for: userID) else { return }
    self.lifestyleID = id
    
    if let lifestyle = context.model(for: id) as? UserLifeStyle {
      self.wakeTime = lifestyle.wakeTimeDate
      self.sleepTime = lifestyle.sleepTimeDate
      self.breakfastTime = lifestyle.breakfastDate
      self.lunchTime = lifestyle.lunchDate
      self.dinnerTime = lifestyle.dinnerDate
    }
  }
  
  func saveLifestyle() async {
    guard let lifestyleID = self.lifestyleID else { return }
    
    await lifestyleStore.setLifestyleTimesDate(
      id: lifestyleID,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      breakfast: breakfastTime,
      lunch: lunchTime,
      dinner: dinnerTime
    )
  }
}
