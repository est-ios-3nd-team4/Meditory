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

     // 해당 날짜에 표시할 Routine 식별자 조회
     let routineIDs = await RoutineStore.shared.fetchRoutineIDs(for: date)

     // 식별자로 Routine 실체 복원
     let routines: [Routine] = routineIDs.compactMap { modelContext.model(for: $0) as? Routine }

     // IntakeItem 구성 (RoutineTime.time의 시/분/초 + date의 연/월/일)
     var items: [IntakeItem] = []
     for routine in routines {
       for rt in routine.routineTimes {
         var comp = cal.dateComponents([.hour, .minute, .second], from: rt.time)
         let dComp = cal.dateComponents([.year, .month, .day], from: date)
         comp.year = dComp.year; comp.month = dComp.month; comp.day = dComp.day

         guard let scheduledTime = cal.date(from: comp) else { continue }
         let completed = isCompleted(routineID: routine.persistentModelID, at: scheduledTime)

         items.append(
           IntakeItem(
             id: rt.id,
             name: routine.displayName,
             time: scheduledTime,
             isCompleted: completed,
             routine: routine
           )
         )
       }
     }

     // 시간 오름차순 정렬
     return items.sorted { $0.time < $1.time }
   }

  /// IntakeItem 체크/해제 토글: 레코드 생성 또는 삭제
  func toggleIntake(_ item: IntakeItem) async {
    let cal = Calendar.current
    let minuteKey = cal.dateTrimToMinute(item.time)

    if item.isCompleted {
      // 이미 체크됨 → 같은 루틴 && 같은 분의 레코드만 삭제
      let all = (try? modelContext.fetch(FetchDescriptor<RoutineRecord>())) ?? []
      if let rec = all.first(where: { rec in
        rec.routine == item.routine &&
        cal.isDate(rec.timestamp, equalTo: minuteKey, toGranularity: .minute)
      }) {
        delete(recordID: rec.persistentModelID)
      }
    } else {
      // 미체크 → 새 레코드 생성
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
