//
//  UserLifeStyleStore.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//

import Foundation
import SwiftData

@ModelActor
actor UserLifeStyleStore {
  static let shared = UserLifeStyleStore(modelContainer: DataController.shared.container)
  
  // MARK: - 조회 및 생성
  
  /// 특정 유저의 LifeStyle ID를 가져오거나, 없으면 기본값으로 생성하여 ID를 반환합니다.
  func fetchOrCreateLifestyleID(for userID: PersistentIdentifier) -> PersistentIdentifier? {
    let descriptor = FetchDescriptor<UserLifeStyle>(
      predicate: #Predicate { $0.user?.persistentModelID == userID }
    )
    
    // 1. 기존 LifeStyle이 있는지 ID로 확인
    if let existingID = try? modelContext.fetch(descriptor).first?.persistentModelID {
      return existingID
    }
    
    // 2. 없으면 새로 생성
    guard let user = modelContext.model(for: userID) as? User else { return nil }
    
    let newLifestyle = UserLifeStyle(
      user: user,
      wakeTime: "07:00",
      sleepTime: "23:30",
      breakfast: nil,
      lunch: "12:30",
      dinner: "19:30"
    )
    modelContext.insert(newLifestyle)
    try? modelContext.save()
    
    return newLifestyle.persistentModelID
  }
  
  // MARK: - 업데이트 (기존 메서드들 유지)
  
  /// 편의 저장 함수: 이 함수는 이제 역할이 모호해지므로 호출되지 않을 가능성이 높지만,
  /// 혹시 모를 호환성을 위해 남겨둡니다. (내부적으로는 아무것도 안 해도 무방)
  /// 모든 업데이트 함수가 스스로 저장하므로 사실상 불필요합니다.
  func saveLifestyle() {
    // 이미 다른 메서드에서 저장이 다 이루어지므로 이 함수는 비워두거나,
    // 만약을 대비해 한번 더 저장 코드를 넣을 수 있습니다.
    try? modelContext.save()
  }
  
  /// 문자열("HH:mm") 기반 일괄 업데이트
  func setLifestyleTimes(
    id lifestyleID: PersistentIdentifier,
    wakeTime: String? = nil,
    sleepTime: String? = nil,
    breakfast: String? = nil,
    lunch: String? = nil,
    dinner: String? = nil
  ) {
    guard let lifestyle = modelContext.model(for: lifestyleID) as? UserLifeStyle else { return }
    
    if let value = wakeTime { lifestyle.wakeTime = value }
    if let value = sleepTime { lifestyle.sleepTime = value }
    
    // breakfast는 Optional이므로 그대로 할당
    if let value = breakfast { lifestyle.breakfast = value }
    if let value = lunch { lifestyle.lunch = value }
    if let value = dinner { lifestyle.dinner = value }
    
    try? modelContext.save()
  }
  
  /// Date 기반 일괄 업데이트 (DatePicker용)
  func setLifestyleTimesDate(
    id lifestyleID: PersistentIdentifier,
    wakeTime: Date? = nil,
    sleepTime: Date? = nil,
    breakfast: Date? = nil,
    lunch: Date? = nil,
    dinner: Date? = nil
  ) {
    guard let lifestyle = modelContext.model(for: lifestyleID) as? UserLifeStyle else { return }
    
    if let date = wakeTime { lifestyle.wakeTime = date.toHHmmString() }
    if let date = sleepTime { lifestyle.sleepTime = date.toHHmmString() }
    
    if let date = breakfast { lifestyle.breakfast = date.toHHmmString() }
    if let date = lunch { lifestyle.lunch = date.toHHmmString() }
    if let date = dinner { lifestyle.dinner = date.toHHmmString() }
    
    try? modelContext.save()
  }
}
