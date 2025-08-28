//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import Foundation
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {
  var intakeItems: [IntakeItem] = []
  var dayCompletionMap: DayCompletionMap = [:]

  /// 메인 스레드에서 사용할 SwiftData 컨텍스트
  @MainActor
  private var context: ModelContext { DataController.shared.container.mainContext }

  var progress: Double {
    guard !intakeItems.isEmpty else { return 0 }
    let doneCount = intakeItems.filter { $0.isCompleted }.count
    return Double(doneCount) / Double(intakeItems.count)
  }

  init() {}

  /// 오늘(선택일)의 섭취 목록 로드
  @MainActor
  func loadIntake(on date: Date) async {
    intakeItems = await buildTodayIntakeItems(on: date)
  }

  /// 체크 토글(인덱스 기반)
  @MainActor
  func toggleCompleted(at index: Int, for date: Date) async {
    guard intakeItems.indices.contains(index) else { return }
    let item = intakeItems[index]
    await toggleCompleted(item, for: date)
  }

  /// 체크 토글(아이템 기반)
  @MainActor
  func toggleCompleted(_ item: IntakeItem, for date: Date) async {
    await toggleIntake(item)                 // 생성/삭제
    await loadIntake(on: date)               // 목록 재구성
    await refreshTodayCompletion(on: date)   // 당일 완료도만 빠르게 갱신
  }

  /// 월간 달력 완료도 전체 재계산
  @MainActor
  func reloadDayCompletions(for baseDate: Date) async {
    let cal = Calendar.current
    guard
      let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: baseDate)),
      let startOfNext  = cal.date(byAdding: .month, value: 1, to: startOfMonth)
    else {
      dayCompletionMap = [:]
      return
    }

    var map: DayCompletionMap = [:]
    var cursor = startOfMonth
    while cursor < startOfNext {
      let (done, total) = await dayCount(on: cursor)
      if total > 0 {
        map[cal.startOfDay(for: cursor)] = Double(done) / Double(total)
      }
      cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
    }
    dayCompletionMap = map
  }

  /// 오늘(선택일)만 빠르게 갱신
  @MainActor
  func refreshTodayCompletion(on day: Date) async {
    let cal = Calendar.current
    let (done, total) = await dayCount(on: day)
    let key = cal.startOfDay(for: day)
    if total > 0 {
      dayCompletionMap[key] = Double(done) / Double(total)
    } else {
      dayCompletionMap[key] = nil
    }
  }

  @MainActor
  private func buildTodayIntakeItems(on date: Date) async -> [IntakeItem] {
    let cal = Calendar.current

    // 해당 날짜에 표시할 Routine 식별자 조회 (ModelActor)
    let routineIDs = await RoutineStore.shared.fetchRoutineIDs(for: date)

    // 식별자로 Routine 실체 복원
    let routines: [Routine] = routineIDs.compactMap { context.model(for: $0) as? Routine }

    // IntakeItem 구성 (RoutineTime.time의 시/분/초 + date의 연/월/일)
    var items: [IntakeItem] = []
    for routine in routines {
      for rt in routine.routineTimes {
        var comp = cal.dateComponents([.hour, .minute, .second], from: rt.time)
        let dComp = cal.dateComponents([.year, .month, .day], from: date)
        comp.year = dComp.year; comp.month = dComp.month; comp.day = dComp.day

        guard let scheduledTime = cal.date(from: comp) else { continue }
        let completed = isCompleted(routine: routine, at: scheduledTime)

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

  /// 특정 루틴/시간에 레코드가 있는지 여부
  @MainActor
  private func isCompleted(routine: Routine, at time: Date) -> Bool {
    let cal = Calendar.current
    let dayRecords = (try? fetchRoutineRecords(on: time)) ?? []
    let targetKey = cal.dateTrimToMinute(time)
    return dayRecords.contains { rec in
      rec.routine == routine && cal.dateTrimToMinute(rec.timestamp) == targetKey
    }
  }

  /// IntakeItem 체크/해제 토글: 레코드 생성 또는 삭제
  @MainActor
  private func toggleIntake(_ item: IntakeItem) async {
    let cal = Calendar.current
    let minuteKey = cal.dateTrimToMinute(item.time)

    if item.isCompleted {
      // 이미 체크됨 → 같은 루틴 && 같은 분의 레코드만 삭제
      let all = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []
      if let rec = all.first(where: { rec in
        rec.routine == item.routine &&
        cal.isDate(rec.timestamp, equalTo: minuteKey, toGranularity: .minute)
      }) {
        context.delete(rec)
        try? context.save()
      }
    } else {
      // 미체크 → 새 레코드 생성 (ModelActor 경유)
      await RoutineStore.shared.createRoutineRecord(
        forRoutineID: item.routine.persistentModelID,
        timestamp: item.time
      )
    }
  }

  /// 특정 날짜의 (완료 수, 전체 수)
  @MainActor
  private func dayCount(on day: Date) async -> (done: Int, total: Int) {
    let cal = Calendar.current

    // 해당 날짜 활성 루틴
    let routineIDs = await RoutineStore.shared.fetchRoutineIDs(for: day)
    let routines = routineIDs.compactMap { context.model(for: $0) as? Routine }

    // 전체 스케줄(분해된 Date)
    let allTimes: [Date] = routines.flatMap { r in
      r.routineTimes.compactMap { scheduledDate(on: day, from: $0.time) }
    }
    let total = allTimes.count

    // 완료 레코드 집합(분 단위 키)
    let doneRecords = (try? fetchRoutineRecords(on: day)) ?? []
    let doneSet: Set<Date> = Set(doneRecords.map { cal.dateTrimToMinute($0.timestamp) })

    // 교집합 크기 = done
    let done = allTimes
      .map { cal.dateTrimToMinute($0) }
      .filter { doneSet.contains($0) }
      .count

    return (done, total)
  }


  @MainActor
  private func fetchRoutineRecords(on day: Date) throws -> [RoutineRecord] {
    let cal = Calendar.current
    let start = cal.startOfDay(for: day)
    guard let next = cal.date(byAdding: .day, value: 1, to: start) else { return [] }

    let predicate = #Predicate<RoutineRecord> { rec in
      rec.timestamp >= start && rec.timestamp < next
    }
    let desc = FetchDescriptor<RoutineRecord>(predicate: predicate)
    return try context.fetch(desc)
  }

  @MainActor
  private func fetchRoutineRecords(inMonthOf baseDate: Date) throws -> [RoutineRecord] {
    let cal = Calendar.current
    guard
      let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: baseDate)),
      let startOfNext  = cal.date(byAdding: .month, value: 1, to: startOfMonth)
    else { return [] }

    let predicate = #Predicate<RoutineRecord> { rec in
      rec.timestamp >= startOfMonth && rec.timestamp < startOfNext
    }
    let desc = FetchDescriptor<RoutineRecord>(predicate: predicate, sortBy: [SortDescriptor(\.timestamp)])
    return try context.fetch(desc)
  }

  @MainActor
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
    return self.date(from: c)! // 정상 경로에서 안전하게 생성
  }
}
