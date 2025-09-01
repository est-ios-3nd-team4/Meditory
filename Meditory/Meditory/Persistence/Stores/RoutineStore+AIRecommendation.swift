//
//  RoutineStore+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation
import SwiftData

extension RoutineStore {
  
  /// 이름으로 특정 `Routine`의 ID를 검색함.
  /// - Parameter name: 검색할 루틴의 `displayName`.
  /// - Returns: 검색된 `Routine`의 `PersistentIdentifier`. 일치하는 루틴이 없으면 `nil`을 반환함.
  func findRoutineID(named name: String) -> PersistentIdentifier? {
    var descriptor = FetchDescriptor<Routine>(predicate: #Predicate { $0.displayName == name })
    descriptor.fetchLimit = 1
    return try? modelContext.fetch(descriptor).first?.persistentModelID
  }
  
  /// AI 추천 결과를 기존 `Routine` 객체에 적용하고 저장함.
  /// - Parameters:
  ///   - dto: AI 추천 결과가 담긴 `SupplementDTO` 객체.
  ///   - routineID: 추천을 적용할 대상 `Routine`의 ID.
  ///   - start: 루틴 시작 날짜. 기본값은 현재 시간임.
  func applyRecommendation(from dto: SupplementDTO, toRoutineID routineID: PersistentIdentifier, start: Date = Date()) {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return }
    
    routine.usage = dto.usage
    routine.precautions = dto.precautions
    
    let (cycleType, cycleValue) = Self.makeCycleFields(from: dto.schedule)
    routine.cycleType = cycleType
    routine.cycleValue = cycleValue
    
    try? modelContext.save()
  }
  
  // MARK: - Private Static Helpers
  
  /// `DoseSchedule`로부터 `cycleType`과 `cycleValue`를 생성함.
  private static func makeCycleFields(from s: DoseSchedule) -> (cycleType: Int, cycleValue: String) {
    switch s.cycleType {
    case .weekday:
      let list = (s.weekdays ?? [])
      return (SupplementScheduleType.weekday.rawValue, list.map(String.init).joined(separator: .separatorCommaSpace))
      
    case .interval:
      if let d = s.intervalDays {
        return (SupplementScheduleType.interval.rawValue, String(10 + d))
      }
      return (SupplementScheduleType.interval.rawValue, "")
    }
  }
  
  /// 기준 시간(`relativeTo`)과 오프셋(`offset`)을 기반으로 사람이 읽을 수 있는 시간 문자열을 생성함.
  private static func formattedOffset(for relativeTo: String, offset: Int) -> String {
    let offsetTimeString: String = {
      let minutes = abs(offset)
      let hours = minutes / 60
      let mins = minutes % 60
      if hours > 0 {
        if mins > 0 {
          return "\(hours)시간 \(mins)분"
        } else {
          return "\(hours)시간"
        }
      }
      return "\(mins)분"
    }()
    
    let timing: String = {
      if offset > 0 { return "후" }
      if offset < 0 { return "전" }
      return " 직후"
    }()
    
    // 식사
    if ["아침", "점심", "저녁"].contains(relativeTo) {
      if offset == 0 { return "\(relativeTo) 직후" }
      let mealTiming = offset > 0 ? "식후" : "식전"
      return "\(relativeTo) \(mealTiming) \(offsetTimeString)"
    }
    
    // 기상/취침
    if ["기상", "취침"].contains(relativeTo) {
      if offset == 0 { return "\(relativeTo) 직후" }
      return "\(relativeTo) \(timing) \(offsetTimeString)"
    }
    
    // 기타 이벤트
    if offset == 0 { return "\(relativeTo) 직후" }
    return "\(relativeTo) \(timing) \(offsetTimeString)"
  }
  
  /// 주어진 날짜(`base`)를 기준으로 특정 시/분으로 설정된 `Date` 객체를 생성함.
  private static func dateOn(_ base: Date, hour: Int, minute: Int,calendar: Calendar = .current) -> Date {
    var dc = calendar.dateComponents([.year, .month, .day], from: base)
    dc.hour = hour
    dc.minute = minute
    dc.second = 0
    return calendar.date(from: dc) ?? base
  }
}
