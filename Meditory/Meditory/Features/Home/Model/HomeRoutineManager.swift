//
//  HomeRoutineManager.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//


import Foundation
import SwiftData

@MainActor
final class HomeRoutineManager {
  private let context: ModelContext
  private let routineStore: RoutineStore

  /// ModelContext와 RoutineStore를 주입받아 초기화
  init(context: ModelContext, routineStore: RoutineStore = RoutineStore()) {
    self.context = context
    self.routineStore = routineStore
  }

  /// 단일 RoutineRecord 삭제
  func delete(record: RoutineRecord) {
    context.delete(record)
    try? context.save()
  }

  /// 특정 루틴/시간에 레코드가 있는지 여부
  func isCompleted(routine: Routine, at time: Date) -> Bool {
    let cal = Calendar.current
    // 해당 '일자' 범위만 조회 후, 분 단위 키로 비교 (초/타임존 오차 방지)
    let dayRecords = (try? fetchRoutineRecords(on: time)) ?? []
    let targetKey = cal.dateTrimToMinute(time)
    return dayRecords.contains { rec in
      rec.routine == routine && cal.dateTrimToMinute(rec.timestamp) == targetKey
    }
  }

  /// 선택한 날짜에 보여줄 IntakeItem 목록
  func fetchTodayIntakeItem(on date: Date) -> [IntakeItem] {
    let calendar = Calendar.current
    let routines = routineStore.fetchRoutines(for: date, context: context)
    var items: [IntakeItem] = []

    for routine in routines {
      for time in routine.routineTimes {
        // RoutineTime.time의 시분초만 추출
        var components = calendar.dateComponents([.hour, .minute, .second], from: time.time)

        // 선택한 날짜의 연월일을 덧씌움
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        components.year = dayComponents.year
        components.month = dayComponents.month
        components.day = dayComponents.day

        guard let scheduledTime = calendar.date(from: components) else { continue }

        let completed = isCompleted(routine: routine, at: scheduledTime)
        items.append(
          IntakeItem(
            id: time.id,
            name: routine.displayName,
            time: scheduledTime,
            isCompleted: completed,
            routine: routine
          )
        )
      }
    }

    return items.sorted { $0.time < $1.time }
  }
  /// IntakeItem 체크/낫체크 토글: 레코드 생성 또는 삭제
  func toggleIntake(_ item: IntakeItem) {
    let allRecords = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []

    if item.isCompleted {
      // 이미 체크된 상태: 해당 시간의 레코드만 삭제
      if let deleteRecord = allRecords.first(where: { record in
        record.routine == item.routine &&
        Calendar.current.isDate(record.timestamp,
                                equalTo: item.time,
                                toGranularity: .minute)
      }) {
        delete(record: deleteRecord)
      }
    } else {
      // 체크 안 된 상태: 새 레코드 생성
      routineStore.createRoutineRecord(
        for: item.routine,
        timestamp: item.time,
        context: context
      )
    }
  }

  /// 월간 범위 레코드
  func fetchRoutineRecords(inMonthOf baseDate: Date) throws -> [RoutineRecord] {
    let cal = Calendar.current
    guard
      let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: baseDate)),
      let startOfNext  = cal.date(byAdding: .month, value: 1, to: startOfMonth)
    else { return [] }

    let predicate = #Predicate<RoutineRecord> { rec in
      rec.timestamp >= startOfMonth && rec.timestamp < startOfNext
    }
    let desc = FetchDescriptor<RoutineRecord>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.timestamp)]
    )
    return try context.fetch(desc)
  }

  /// 하루 범위 레코드
  func fetchRoutineRecords(on day: Date) throws -> [RoutineRecord] {
    let cal = Calendar.current
    let start = cal.startOfDay(for: day)
    guard let next = cal.date(byAdding: .day, value: 1, to: start) else { return [] }

    let predicate = #Predicate<RoutineRecord> { rec in
      rec.timestamp >= start && rec.timestamp < next
    }
    let desc = FetchDescriptor<RoutineRecord>(predicate: predicate)
    return try context.fetch(desc)
  }

  /// 특정 날짜의 (완료 수, 전체 수)
  func dayCount(on day: Date) -> (done: Int, total: Int) {
    let cal = Calendar.current
    let routines = routineStore.fetchRoutines(for: day, context: context)

    // 그 날 예정된 모든 시각
    let allTimes: [Date] = routines.flatMap { r in
      r.routineTimes.compactMap { scheduledDate(on: day, from: $0.time) }
    }
    let total = allTimes.count

    // 완료된 분 키 세트
    let doneRecords = (try? fetchRoutineRecords(on: day)) ?? []
    let doneSet: Set<Date> = Set(doneRecords.map { cal.dateTrimToMinute($0.timestamp) })

    // 분 단위로 키 변환하여 교집합 카운트
    let done = allTimes
      .map { cal.dateTrimToMinute($0) }
      .filter { doneSet.contains($0) }
      .count

    return (done, total)
  }

  // MARK: - Private

  /// `time`의 시/분/초를 `day`의 연-월-일에 덮어쓴 Date
  private func scheduledDate(on day: Date, from time: Date) -> Date? {
    let cal = Calendar.current
    var comp = cal.dateComponents([.hour, .minute, .second], from: time)
    let d = cal.dateComponents([.year, .month, .day], from: day)
    comp.year = d.year; comp.month = d.month; comp.day = d.day
    return cal.date(from: comp)
  }
}

private extension Calendar {
  /// 초 미만 오차/타임존 보정을 피하기 위해 분 단위로 고정
  func dateTrimToMinute(_ date: Date) -> Date {
    let c = dateComponents([.year, .month, .day, .hour, .minute], from: date)
    // 정상 경로에서 안전하게 생성
    return self.date(from: c)!
  }
}
