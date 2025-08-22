//
//  HomeRoutineManager.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//


import Foundation
import SwiftData

@ModelActor
actor HomeRoutineManager {
  static let shared = HomeRoutineManager(modelContainer: DataController.shared.container)

  /// ID로 단일 RoutineRecord 삭제
  func delete(recordID: PersistentIdentifier) {
    guard let record = modelContext.model(for: recordID) as? RoutineRecord else { return }
    modelContext.delete(record)
    try? modelContext.save()
  }

  /// 특정 루틴/시간에 레코드가 있는지 여부
  func isCompleted(routineID: PersistentIdentifier, at time: Date) -> Bool {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return false }
    
    let cal = Calendar.current
    let dayRecords = (try? fetchRoutineRecords(on: time)) ?? []
    let targetKey = cal.dateTrimToMinute(time)
    return dayRecords.contains { rec in
      rec.routine == routine && cal.dateTrimToMinute(rec.timestamp) == targetKey
    }
  }

  /// 선택한 날짜에 보여줄 IntakeItem 목록
  func fetchTodayIntakeItems(on date: Date) async -> [IntakeItem] {
    let cal = Calendar.current
    
    // 1. RoutineStore 액터로부터 Routine ID 목록을 비동기적으로 가져옴
    let routineIDs = await RoutineStore.shared.fetchRoutineIDs(for: date)
    
    // 2. ID를 사용해 현재 액터의 컨텍스트에서 실제 Routine 객체들을 가져옴
    let routines = routineIDs.compactMap { modelContext.model(for: $0) as? Routine }

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
            name: routine.displayName,
            time: scheduled,
            isCompleted: isDone,
            routine: routine
          )
        )
      }
    }
    return items.sorted { $0.time < $1.time }
  }

  /// IntakeItem 체크/해제 토글: 레코드 생성 또는 삭제
  func toggleIntake(_ item: IntakeItem) async {
    let cal = Calendar.current
    let dayRecords = (try? fetchRoutineRecords(on: item.time)) ?? []
    let targetKey = cal.dateTrimToMinute(item.time)

    if let rec = dayRecords.first(where: {
      $0.routine == item.routine && cal.dateTrimToMinute($0.timestamp) == targetKey
    }) {
      // 이미 존재 → 삭제
      delete(recordID: rec.persistentModelID)
    } else {
      // 없으면 생성 (RoutineStore 액터에 요청)
      await RoutineStore.shared.createRoutineRecord(
        forRoutineID: item.routine.persistentModelID,
        timestamp: item.time
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
    let desc = FetchDescriptor<RoutineRecord>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp)])
    return try modelContext.fetch(desc)
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
    return try modelContext.fetch(desc)
  }

  /// 특정 날짜의 (완료 수, 전체 수)
  func dayCount(on day: Date) async -> (done: Int, total: Int) {
    let cal = Calendar.current
    
    let routineIDs = await RoutineStore.shared.fetchRoutineIDs(for: day)
    let routines = routineIDs.compactMap { modelContext.model(for: $0) as? Routine }

    let allTimes: [Date] = routines.flatMap { r in
      r.routineTimes.compactMap { scheduledDate(on: day, from: $0.time) }
    }
    let total = allTimes.count

    let doneRecords = (try? fetchRoutineRecords(on: day)) ?? []
    let doneSet: Set<Date> = Set(doneRecords.map { cal.dateTrimToMinute($0.timestamp) })

    let done = allTimes
      .map { cal.dateTrimToMinute($0) }
      .filter { doneSet.contains($0) }
      .count

    return (done, total)
  }

  // MARK: - Private

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
