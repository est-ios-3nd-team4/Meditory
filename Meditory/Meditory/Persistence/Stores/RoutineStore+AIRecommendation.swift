//
//  RoutineStore+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation
import SwiftData

extension RoutineStore {
  
  /// 이름으로 특정 Routine의 ID를 찾습니다.
  func findRoutineID(named name: String) -> PersistentIdentifier? {
    var descriptor = FetchDescriptor<Routine>(predicate: #Predicate { $0.displayName == name })
    descriptor.fetchLimit = 1
    return try? modelContext.fetch(descriptor).first?.persistentModelID
  }

  /// AI 추천 결과를 기존 Routine에 반영합니다.
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
  /// cycletype 따라서 변환
  private static func makeCycleFields(from s: DoseSchedule) -> (cycleType: Int, cycleValue: String) {
    switch s.cycleType {
    case .weekday:
      let list = (s.weekdays ?? [])
      return (SupplementScheduleType.weekday.rawValue, list.map(String.init).joined(separator: ","))

    case .interval:
      if let d = s.intervalDays {
        return (SupplementScheduleType.interval.rawValue, String(10 + d))
      }
      return (SupplementScheduleType.interval.rawValue, "")
    }
  }

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

  private static func dateOn(_ base: Date, hour: Int, minute: Int,calendar: Calendar = .current) -> Date {
    var dc = calendar.dateComponents([.year, .month, .day], from: base)
    dc.hour = hour
    dc.minute = minute
    dc.second = 0
    return calendar.date(from: dc) ?? base
  }
}
