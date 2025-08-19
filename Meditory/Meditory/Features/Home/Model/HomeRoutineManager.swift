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
    let cal = Calendar.current
    let routines = routineStore.fetchRoutines(for: date, context: context)

    // 해당 '일자' 레코드만 조회
    let dayRecords = (try? fetchRoutineRecords(on: date)) ?? []
    let completedSet: Set<Date> = Set(dayRecords.map { cal.dateTrimToMinute($0.timestamp) })

    var items: [IntakeItem] = []
    for routine in routines {
      for t in routine.routineTimes {
        guard let scheduled = scheduledDate(on: date, from: t.time) else { continue }
        let key = cal.dateTrimToMinute(scheduled)
        let isDone = completedSet.contains(key)

        items.append(
          IntakeItem(
            id: t.id,
            name: routine.category ?? routine.displayName,
            time: scheduled,
            isCompleted: isDone,
            routine: routine
          )
        )
      }
    }

    return items.sorted { $0.time < $1.time }
  }

  /// IntakeItem 체크/낫체크 토글: 레코드 생성 또는 삭제
  func toggleIntake(_ item: IntakeItem) {
    let cal = Calendar.current
    let dayRecords = (try? fetchRoutineRecords(on: item.time)) ?? []
    let targetKey = cal.dateTrimToMinute(item.time)

    if let rec = dayRecords.first(where: {
      $0.routine == item.routine && cal.dateTrimToMinute($0.timestamp) == targetKey
    }) {
      // 이미 존재 → 삭제
      delete(record: rec)
    } else {
      // 없으면 생성
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
