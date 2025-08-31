//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import Foundation
import SwiftData
import SwiftUI

/// 홈 화면 데이터 로딩·가공·상태 관리를 담당하는 ViewModel입니다.
/// - 역할:
///   - 선택한 날짜의 섭취 항목 목록(`intakeItems`) 구성
///   - 날짜별 달성률 맵(`dayCompletionMap`) 계산 및 유지
///   - 개별 섭취 항목의 완료/해제 토글 처리 (레코드 생성·삭제)
/// - 스레드:
///   - SwiftUI 바인딩 및 SwiftData 메인 컨텍스트 접근을 위해 주요 메서드는 `@MainActor`에서 동작합니다.
@Observable
final class HomeViewModel {
  /// UI에 표시할 당일(선택일) 섭취 항목 목록입니다.
  /// - `IntakeItem`에는 항목명, 예정 시간, 완료 여부, 연결된 `Routine` 등이 포함됩니다.
  var intakeItems: [IntakeItem] = []
  
  /// 캘린더 배경에 표시할 날짜별 완료도 맵입니다.
  /// - Key: 날짜의 시작 시각(자정) / Value: 달성률(0.0~1.0)
  var dayCompletionMap: DayCompletionMap = [:]
  
  /// 메인 스레드에서 사용할 SwiftData 컨텍스트입니다.
  /// - `DataController.shared.container.mainContext`를 통해 접근합니다.
  @MainActor
  private var context: ModelContext { DataController.shared.container.mainContext }
  
  /// 현재 `intakeItems` 기반의 달성률(0.0~1.0)입니다.
  /// - 완료된 항목 수 / 전체 항목 수로 계산됩니다.
  var progress: Double {
    guard !intakeItems.isEmpty else { return 0 }
    let doneCount = intakeItems.filter { $0.isCompleted }.count
    return Double(doneCount) / Double(intakeItems.count)
  }
  
  init() {}
  
  // MARK: - Public APIs
  
  /// 선택한 날짜의 섭취 목록을 로드합니다.
  /// - Parameter date: 기준 날짜
  /// - Note: 내부적으로 `buildTodayIntakeItems(on:)`를 호출합니다.
  @MainActor
  func loadIntake(on date: Date) async {
    intakeItems = await buildTodayIntakeItems(on: date)
  }
  
  /// 체크 토글(인덱스 기반) 메서드입니다.
  /// - Parameters:
  ///   - index: `intakeItems`의 인덱스
  ///   - date: 기준 날짜(토글 이후 목록/달성도 갱신에 사용)
  /// - Warning: 인덱스 범위 외 접근을 방지합니다.
  @MainActor
  func toggleCompleted(at index: Int, for date: Date) async {
    guard intakeItems.indices.contains(index) else { return }
    let item = intakeItems[index]
    await toggleCompleted(item, for: date)
  }
  
  /// 체크 토글(아이템 기반) 메서드입니다.
  /// - 완료 상태에 따라 레코드를 생성하거나 삭제한 뒤,
  ///   당일 목록과 당일 달성도를 즉시 갱신합니다.
  /// - Parameters:
  ///   - item: 토글 대상 섭취 항목
  ///   - date: 기준 날짜
  @MainActor
  func toggleCompleted(_ item: IntakeItem, for date: Date) async {
    await toggleIntake(item)                 // 완료/미완료 반영 (레코드 생성/삭제)
    await loadIntake(on: date)               // 목록 재구성
    await refreshTodayCompletion(on: date)   // 당일 달성도만 빠르게 갱신
  }
  
  /// 해당 월의 모든 날짜에 대해 달력 완료도를 재계산합니다.
  /// - Parameter baseDate: 기준이 되는 달(해당 달 전체를 계산)
  /// - Note: `Calendar.startOfDay` 기준으로 Key를 설정합니다.
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
  
  /// 특정 일자(당일)만 빠르게 달성도를 갱신합니다.
  /// - Parameter day: 기준 날짜
  /// - Note: 월 전체를 재계산하지 않고 해당 일만 반영합니다.
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
  
  // MARK: - Builders
  
  /// 선택한 날짜에 표시할 섭취 항목 목록을 구성합니다.
  /// - RoutineTime의 시/분/초를 기준 날짜의 연/월/일과 결합하여 스케줄 시각을 만듭니다.
  /// - 완료 여부는 해당 분 단위에 레코드가 존재하는지로 판별합니다.
  /// - Parameter date: 기준 날짜
  /// - Returns: 시간 오름차순으로 정렬된 `IntakeItem` 배열
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
  
  // MARK: - State Checks & Mutations
  
  /// 특정 루틴/시간에 해당하는 완료 레코드 존재 여부를 반환합니다.
  /// - 같은 분(minute) 단위 비교를 통해 판별합니다.
  /// - Parameters:
  ///   - routine: 대상 루틴
  ///   - time: 대상 시각
  /// - Returns: 완료 여부
  @MainActor
  private func isCompleted(routine: Routine, at time: Date) -> Bool {
    let cal = Calendar.current
    let dayRecords = (try? fetchRoutineRecords(on: time)) ?? []
    let targetKey = cal.dateTrimToMinute(time)
    return dayRecords.contains { rec in
      rec.routine == routine && cal.dateTrimToMinute(rec.timestamp) == targetKey
    }
  }
  
  /// 섭취 항목의 완료 상태를 토글합니다.
  /// - 완료 상태라면 동일 루틴·동일 분의 레코드를 삭제,
  ///   미완료 상태라면 레코드를 생성합니다.
  /// - Parameter item: 토글할 섭취 항목
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
  
  // MARK: - Aggregations
  
  /// 특정 날짜의 달성 집계 결과를 반환합니다.
  /// - 완료 수(done)와 전체 수(total)를 함께 제공합니다.
  /// - Parameter day: 기준 날짜
  /// - Returns: `(done, total)`
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
  
  // MARK: - Fetch Helpers
  
  /// 특정 날짜 범위(자정~다음날 자정)의 `RoutineRecord`를 조회합니다.
  /// - Parameter day: 기준 날짜
  /// - Returns: 해당 일자에 속하는 레코드 목록
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
  
  /// 특정 월 범위의 `RoutineRecord`를 조회합니다.
  /// - Parameter baseDate: 기준 월
  /// - Returns: 해당 월의 모든 레코드(시간순 정렬)
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
  
  /// 루틴의 `RoutineTime`(시/분/초)을 기준 날짜의 연/월/일과 결합하여 실제 스케줄 시각을 생성합니다.
  /// - Parameters:
  ///   - day: 기준 날짜(연/월/일 사용)
  ///   - time: 루틴에 저장된 시간 정보(시/분/초 사용)
  /// - Returns: 결합된 `Date`(스케줄 시각)
  @MainActor
  private func scheduledDate(on day: Date, from time: Date) -> Date? {
    let cal = Calendar.current
    var comp = cal.dateComponents([.hour, .minute, .second], from: time)
    let d = cal.dateComponents([.year, .month, .day], from: day)
    comp.year = d.year; comp.month = d.month; comp.day = d.day
    return cal.date(from: comp)
  }
}

// MARK: - Utilities

private extension Calendar {
  /// 분 단위까지만 유지한 `Date`를 생성합니다.
  /// - 초 미만 오차 및 타임존 이슈를 피하기 위해 사용합니다.
  /// - Parameter date: 원본 시각
  /// - Returns: 연-월-일-시-분만 유지한 시각
  func dateTrimToMinute(_ date: Date) -> Date {
    let c = dateComponents([.year, .month, .day, .hour, .minute], from: date)
    return self.date(from: c)! // 정상 경로에서 안전하게 생성
  }
}
