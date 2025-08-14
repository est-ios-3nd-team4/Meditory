//
//  RoutineStore+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation
import SwiftData

@MainActor
extension RoutineStore {
  func findRoutine(named name: String, context: ModelContext) -> Routine? {
    var descriptor = FetchDescriptor<Routine>(predicate: #Predicate { $0.displayName == name })
    descriptor.fetchLimit = 1
    return try? context.fetch(descriptor).first
  }

  /// AI 추천 결과 Ruotine 반영
  func applyRecommendation(from dto: SupplementDTO, to routine: Routine, start: Date = Date(), context: ModelContext) {
    routine.type = dto.type
    routine.pillsPerDose = dto.pillsPerDose
    routine.usage = dto.usage
    routine.precautions = dto.precautions

    let (cycleType, cycleValue) = Self.makeCycleFields(from: dto.schedule)
    routine.cycleType = cycleType
    routine.cycleValue = cycleValue

    replaceRecommendedTimes(of: routine, with: dto.schedule.times, startDate: start)

    try? context.save()
  }

  /// 추천 복용 시간 대체
  private func replaceRecommendedTimes(of routine: Routine, with timeSpecs: [TimeSpec], startDate: Date) {
    routine.recommendedRoutineTimes.removeAll()

    let newTimes: [RoutineTime] = timeSpecs.compactMap { spec in
      switch spec {
      case let .absolute(h, m):
        return RoutineTime(
          time: Self.dateOn(startDate, hour: h, minute: m),
          routine: routine
        )

      case let .relative(ref, offset):
        return RoutineTime(
          time: Self.dateOn(startDate, hour: 0, minute: 0),
          intakeTiming: Self.formattedOffset(for: ref, offset: offset),
          intakeOffsetMinutes: offset,
          routine: routine
        )
      }
    }

    routine.recommendedRoutineTimes = newTimes
  }

  /// cycletype 따라서 변환
  private static func makeCycleFields(from s: DoseSchedule) -> (cycleType: Int, cycleValue: String) {
    switch s.cycleType {
    case .weekdays:
      let list = (s.weekdays ?? [])
      return (CycleType.weekdays.rawValue, list.map(String.init).joined(separator: ","))

    case .interval:
      if let d = s.intervalDays {
        return (CycleType.interval.rawValue, String(10 + d))
      }

      return (CycleType.interval.rawValue, "")
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
