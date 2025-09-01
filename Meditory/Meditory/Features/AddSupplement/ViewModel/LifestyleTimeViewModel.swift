//
//  LifestyleTimeViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/16/25.
//

import Foundation
import SwiftData

/// 사용자의 생활 패턴(기상, 취침, 식사 시간)을 관리하는 ViewModel
@Observable
final class LifestyleTimeViewModel {
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
  
  var userLifestyle: UserLifeStyleDTO? {
    guard let wakeTime, let sleepTime else { return nil }
    
    return UserLifeStyleDTO(
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
  
  /// 사용자가 선택한 시간을 반영 (변경이 있을 경우 true 반환)
  func setTime(_ result: LifestyleTimeResult) -> Bool {
    var didChange = false
    
    func updateIfChanged<T: Equatable>(_ current: inout T?, _ newValue: T?) {
      if current != newValue {
        current = newValue
        didChange = true
      }
    }
    
    switch result {
    case .dailyCycle(let dailyCycleTimes):
      for item in dailyCycleTimes {
        switch item.type {
        case .wakeTime:
          updateIfChanged(&wakeTime, item.time)
          break
        case .sleepTime:
          updateIfChanged(&sleepTime, item.time)
        }
      }
      
    case .meal(let mealTimes):
      for item in mealTimes {
        let newValue = item.isEaten ? item.time : nil
        switch item.type {
        case .breakfast:
          updateIfChanged(&breakfastTime, newValue)
        case .lunch:
          updateIfChanged(&lunchTime, newValue)
        case .dinner:
          updateIfChanged(&dinnerTime, newValue)
        }
      }
    }
    
    return didChange
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
  
  func saveLifestyle() async throws {
    guard let lifestyleID = self.lifestyleID else { return }
    
    try await lifestyleStore.setLifestyleTimesDate(
      id: lifestyleID,
      wakeTime: wakeTime,
      sleepTime: sleepTime,
      breakfast: breakfastTime,
      lunch: lunchTime,
      dinner: dinnerTime
    )
  }
}
