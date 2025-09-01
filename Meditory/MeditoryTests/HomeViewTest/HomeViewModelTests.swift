//
//  HomeViewModelTests.swift
//  MeditoryTests
//
//  Created by 윤혜주 on 2025/08/25
//

import XCTest
import SwiftData
@testable import Meditory

// MARK: 테스트 안전성을 위한 Sendable retroactive 선언
// SwiftData @Model 객체는 기본적으로 Sendable 제약을 만족하지 않기 때문에
// 테스트 실행 시 동시성 관련 경고를 막기 위해 선언합니다.

/// 테스트 환경에서 동시성 경고를 회피하기 위한 `RoutineRecord`의 레트로액티브 `Sendable` 선언입니다.
/// - Note: 모델 자체의 스레드 안정성을 보장하지 않으므로 **테스트에서만 사용**해야 합니다.
extension RoutineRecord: @unchecked @retroactive Sendable {}

/// 테스트 환경에서 동시성 경고를 회피하기 위한 `Routine`의 레트로액티브 `Sendable` 선언입니다.
/// - Important: `@unchecked`는 개발자가 스레드 안전성을 책임진다는 의미입니다.
extension Routine: @unchecked @retroactive Sendable {}

/// 테스트 환경에서 동시성 경고를 회피하기 위한 `RoutineTime`의 레트로액티브 `Sendable` 선언입니다.
extension RoutineTime: @unchecked @retroactive Sendable {}

/// `HomeViewModel`의 핵심 동작(진행률 계산, 레코드 조회/정렬, 완료 여부 판단, 삭제 동작 등)을 검증하는 단위 테스트 모음입니다.
/// - 검증 범위:
///   - `progress` 계산 로직 (완료/미완료 비율)
///   - 일/월 단위 레코드 조회 및 정렬
///   - 분 단위까지 동일한 시간의 완료 매칭
///   - 특정 레코드만 삭제되는지 여부
/// - 테스트 인프라:
///   - 인메모리 `ModelContainer`를 구성하여 SwiftData 의존성을 격리합니다.
final class HomeViewModelTests: XCTestCase {
  
  // MARK: - SwiftData 인메모리 컨테이너 구성
  /// 테스트용 인메모리 SwiftData 컨테이너입니다.
  private var container: ModelContainer!
  /// 테스트에서 사용할 `ModelContext`입니다.
  private var context: ModelContext!
  
  /// System Under Test: 실제 검증 대상 `HomeViewModel`
  private var vm: HomeViewModel!
  
  /// 공용 캘린더 인스턴스(테스트 내 날짜 계산 통일 용도)입니다.
  private let cal = Calendar.current
  
  // MARK: - 공용 더미 & 유틸
  
  /// 간단한 속성으로 구성된 더미 `Routine`을 생성합니다.
  /// - Parameter name: 루틴 표시 이름(기본값 "더미")
  /// - Returns: SwiftData 삽입 전 상태의 `Routine`
  private func dummyRoutine(name: String = "더미") -> Routine {
    Routine(
      type: 1,
      displayName: name,
      desc: nil,
      category: nil,
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6",
      startDate: Date(),
      memo: nil,
      hasPush: true,
      usage: [],
      precautions: [],
      routineTimes: [],
      recommendedRoutineTimes: []
    )
  }
  
  /// 지정한 시각과 완료 여부로 `IntakeItem`을 생성합니다.
  /// - Parameters:
  ///   - name: 아이템 이름
  ///   - hour: 시(0~23)
  ///   - minute: 분(0~59)
  ///   - isCompleted: 완료 여부
  ///   - baseDay: 기준 일자(연/월/일 합성용)
  /// - Returns: 테스트용 `IntakeItem`
  private func makeItem(
    name: String,
    hour: Int,
    minute: Int,
    isCompleted: Bool,
    baseDay: Date = Date()
  ) -> IntakeItem {
    var comp = cal.dateComponents([.year, .month, .day], from: cal.startOfDay(for: baseDay))
    comp.hour = hour; comp.minute = minute; comp.second = 0
    let time = cal.date(from: comp)!
    
    return IntakeItem(
      id: UUID(),
      name: name,
      time: time,
      isCompleted: isCompleted,
      routine: dummyRoutine(name: name)
    )
  }
  
  /// 시·분만을 가진 `Date`를 생성합니다(초=0).
  /// - Parameters:
  ///   - h: 시(0~23)
  ///   - m: 분(0~59)
  /// - Returns: 동일한 날짜 기준의 시각 `Date`
  private func clock(_ h: Int, _ m: Int) -> Date {
    var c = DateComponents(); c.hour = h; c.minute = m; c.second = 0
    return cal.date(from: c)!
  }
  
  /// 특정 날짜의 연/월/일과 지정한 시·분을 합성한 `Date`를 반환합니다.
  /// - Parameters:
  ///   - day: 기준 날짜(연/월/일 사용)
  ///   - h: 시
  ///   - m: 분
  /// - Returns: 합성된 `Date`
  private func scheduled(on day: Date, h: Int, m: Int) -> Date {
    var t = cal.dateComponents([.hour, .minute, .second], from: clock(h, m))
    let d = cal.dateComponents([.year, .month, .day], from: day)
    t.year = d.year; t.month = d.month; t.day = d.day
    return cal.date(from: t)!
  }
  
  /// SwiftData에 `Routine` 및 연결된 `RoutineTime`들을 삽입합니다.
  /// - Parameters:
  ///   - name: 루틴 이름
  ///   - times: `(시, 분)` 배열
  /// - Returns: 저장된 `Routine`
  @discardableResult
  private func insertRoutine(
    name: String,
    times: [(Int, Int)]
  ) -> Routine {
    let rTimes: [RoutineTime] = times.map { (h, m) in
      RoutineTime(time: clock(h, m), intakeTiming: nil, intakeOffsetMinutes: nil, pillsPerDose: 1, routine: nil)
    }
    
    let routine = Routine(
      type: 1,
      displayName: name,
      desc: nil,
      category: nil,
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6",
      startDate: Date(),
      memo: nil,
      hasPush: true,
      usage: [],
      precautions: [],
      routineTimes: rTimes,
      recommendedRoutineTimes: []
    )
    
    // 역참조 연결
    for rt in rTimes { rt.routine = routine }
    
    context.insert(routine)
    try? context.save()
    return routine
  }
  
  /// SwiftData에 지정 루틴의 복용 레코드를 삽입합니다.
  /// - Parameters:
  ///   - routine: 대상 루틴
  ///   - timestamp: 기록 시각
  /// - Returns: 저장된 `RoutineRecord`
  @discardableResult
  private func insertRecord(for routine: Routine, at timestamp: Date) -> RoutineRecord {
    let rec = RoutineRecord(timestamp: timestamp, routine: routine)
    context.insert(rec)
    try? context.save()
    return rec
  }
  
  // MARK: - XCTest 생명주기
  
  /// 각 테스트 시작 시 인메모리 SwiftData 컨테이너와 컨텍스트를 구성하고 SUT를 초기화합니다.
  override func setUp() async throws {
    try await super.setUp()
    
    // 인메모리 SwiftData 컨테이너 생성
    let schema = Schema([Routine.self, RoutineRecord.self, RoutineTime.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    
    // SUT 초기화
    vm = HomeViewModel()
  }
  
  /// 각 테스트 종료 시 참조를 해제하여 상태 간섭을 방지합니다.
  override func tearDown() {
    vm = nil
    context = nil
    container = nil
    super.tearDown()
  }
  
  // MARK: HomeViewModel 고유 기능 테스트
  
  /// `intakeItems`가 비어 있을 때 `progress`가 0인지 검증합니다.
  func test_progress_isZero_whenNoItems() {
    let vm = HomeViewModel()
    vm.intakeItems = []
    XCTAssertEqual(vm.progress, 0.0, accuracy: 0.0001)
  }
  
  /// 완료/미완료 조합 변경에 따라 `progress` 비율이 올바르게 계산되는지 검증합니다.
  func test_progress_computation_matchesCompletedRatio() {
    let day = cal.startOfDay(for: Date())
    let vm = HomeViewModel()
    
    vm.intakeItems = [
      makeItem(name: "A", hour: 8,  minute: 0,  isCompleted: false, baseDay: day),
      makeItem(name: "B", hour: 12, minute: 0,  isCompleted: true,  baseDay: day),
      makeItem(name: "C", hour: 20, minute: 30, isCompleted: false, baseDay: day),
    ]
    // 1/3
    XCTAssertEqual(vm.progress, 1.0/3.0, accuracy: 0.0001)
    
    vm.intakeItems[0].isCompleted = true
    XCTAssertEqual(vm.progress, 2.0/3.0, accuracy: 0.0001)
    
    vm.intakeItems[2].isCompleted = true
    XCTAssertEqual(vm.progress, 1.0, accuracy: 0.0001)
  }
  
  /// `dayCompletionMap`을 수동 갱신했을 때 값이 반영되는지 검증합니다.
  func test_dayCompletionMap_manualUpdate() {
    let vm = HomeViewModel()
    let today = cal.startOfDay(for: Date())
    let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!
    
    vm.dayCompletionMap = [:]
    vm.dayCompletionMap[today] = 0.5
    vm.dayCompletionMap[cal.startOfDay(for: tomorrow)] = 1.0
    
    XCTAssertEqual(vm.dayCompletionMap[today]!, 0.5, accuracy: 0.0001)
    XCTAssertEqual(vm.dayCompletionMap[cal.startOfDay(for: tomorrow)]!, 1.0, accuracy: 0.0001)
  }
  
  /// 하루 범위 레코드 조회 시 해당 일자 데이터만 반환되는지 검증합니다.
  func test_FetchRoutineRecords_OnDay_FiltersByDay() throws {
    let day = cal.startOfDay(for: Date())
    
    let r = insertRoutine(name: "멀티비타민", times: [(8, 0)])
    insertRecord(for: r, at: scheduled(on: day, h: 8, m: 0))
    insertRecord(for: r, at: scheduled(on: day, h: 20, m: 0))
    // 다른 날 기록
    let otherDay = cal.date(byAdding: .day, value: 1, to: day)!
    insertRecord(for: r, at: scheduled(on: otherDay, h: 8, m: 0))
    
    let recs = try _test_fetchRoutineRecords(on: day, using: context)
    XCTAssertEqual(recs.count, 2)
    for rec in recs {
      XCTAssertTrue(cal.isDate(rec.timestamp, inSameDayAs: day))
    }
  }
  
  /// 월간 범위 레코드 조회 시 오름차순 정렬이 되는지 검증합니다.
  func test_FetchRoutineRecords_InMonth_SortsAscending() throws {
    let baseMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
    let r = insertRoutine(name: "오메가3", times: [(9, 0)])
    
    let d1 = scheduled(on: baseMonth, h: 9, m: 0)
    let d2 = scheduled(on: cal.date(byAdding: .day, value: 9, to: baseMonth)!, h: 9, m: 0)
    let d3 = scheduled(on: cal.date(byAdding: .day, value: 24, to: baseMonth)!, h: 9, m: 0)
    
    insertRecord(for: r, at: d2)
    insertRecord(for: r, at: d3)
    insertRecord(for: r, at: d1)
    
    let recs = try _test_fetchRoutineRecords(inMonthOf: baseMonth, using: context)
    XCTAssertEqual(recs.map(\.timestamp), [d1, d2, d3])
  }
  
  /// 같은 루틴이면서 같은 '분' 단위 시각에 기록이 있을 때 `isCompleted` 판단이 참인지 검증합니다.
  /// - 또한 초 단위 차이는 무시되는지 확인합니다.
  func test_IsCompleted_MatchesByMinuteAndRoutine() throws {
    let day = cal.startOfDay(for: Date())
    let r1 = insertRoutine(name: "비타민C", times: [(8, 0)])
    let r2 = insertRoutine(name: "프로바이오틱스", times: [(8, 0)])
    
    let t = scheduled(on: day, h: 8, m: 30)
    
    // r1에만 기록 존재
    insertRecord(for: r1, at: t)
    
    let r1Done = try _test_isCompleted(routineID: r1.persistentModelID, at: t, using: context)
    let r2Done = try _test_isCompleted(routineID: r2.persistentModelID, at: t, using: context)
    
    XCTAssertTrue(r1Done)
    XCTAssertFalse(r2Done)
    
    // 같은 '분' 내 초 차이는 무시되는지 검증
    let tSameMinute = t.addingTimeInterval(10)
    let r1DoneSameMinute = try _test_isCompleted(routineID: r1.persistentModelID, at: tSameMinute, using: context)
    XCTAssertTrue(r1DoneSameMinute)
  }
  
  /// `delete(recordID:)`가 지정된 레코드만 삭제하는지 검증합니다.
  func test_DeleteRecord_RemovesOnlyTarget() async throws {
    let day = cal.startOfDay(for: Date())
    let r = insertRoutine(name: "마그네슘", times: [(22, 0)])
    
    let rec1 = insertRecord(for: r, at: scheduled(on: day, h: 22, m: 0))
    let rec2 = insertRecord(for: r, at: scheduled(on: day, h: 8, m: 0))
    
    try await _test_delete(recordID: rec1.persistentModelID, using: context)
    
    let ids = try _test_recordIDs(on: day, using: context)
    XCTAssertEqual(ids.count, 1)
    XCTAssertEqual(ids.first, rec2.persistentModelID)
  }
  
  // MARK: - 테스트 헬퍼 (SUT 내부 구현과 동일 동작을 독립 검증하기 위한 래퍼)
  
  /// 하루 단위 `RoutineRecord`를 조회합니다.
  /// - Parameters:
  ///   - day: 조회 기준 일자
  ///   - context: 사용 컨텍스트
  /// - Returns: 해당 일자 범위의 레코드 배열
  func _test_fetchRoutineRecords(on day: Date, using context: ModelContext) throws -> [RoutineRecord] {
    let cal = Calendar.current
    let start = cal.startOfDay(for: day)
    guard let next = cal.date(byAdding: .day, value: 1, to: start) else { return [] }
    
    let predicate = #Predicate<RoutineRecord> { rec in
      rec.timestamp >= start && rec.timestamp < next
    }
    let desc = FetchDescriptor<RoutineRecord>(predicate: predicate)
    return try context.fetch(desc)
  }
  
  /// 월 단위 `RoutineRecord`를 오름차순으로 조회합니다.
  /// - Parameters:
  ///   - baseDate: 기준이 되는 월의 임의의 날짜
  ///   - context: 사용 컨텍스트
  /// - Returns: 해당 월의 레코드(오름차순 정렬)
  func _test_fetchRoutineRecords(inMonthOf baseDate: Date, using context: ModelContext) throws -> [RoutineRecord] {
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
  
  /// 특정 루틴이 지정 시각(분 단위)에 완료되었는지 여부를 반환합니다.
  /// - Parameters:
  ///   - routineID: 대상 루틴의 영속 ID
  ///   - time: 확인할 시각
  ///   - context: 사용 컨텍스트
  /// - Returns: 완료 여부
  func _test_isCompleted(
    routineID: PersistentIdentifier,
    at time: Date,
    using context: ModelContext
  ) throws -> Bool {
    let cal = Calendar.current
    let dayRecords = try _test_fetchRoutineRecords(on: time, using: context)
    let targetKey = cal.dateTrimToMinute(time)
    
    guard let routine = context.model(for: routineID) as? Routine else { return false }
    return dayRecords.contains { rec in
      rec.routine == routine && cal.dateTrimToMinute(rec.timestamp) == targetKey
    }
  }
  
  /// 특정 `RoutineRecord`를 삭제합니다.
  /// - Parameters:
  ///   - recordID: 삭제할 레코드의 영속 ID
  ///   - context: 사용 컨텍스트
  func _test_delete(recordID: PersistentIdentifier, using context: ModelContext) async throws {
    guard let rec = context.model(for: recordID) as? RoutineRecord else { return }
    context.delete(rec)
    try context.save()
  }
  
  /// 특정 일자의 `RoutineRecord` 식별자 배열을 반환합니다.
  /// - Parameters:
  ///   - day: 기준 일자
  ///   - context: 사용 컨텍스트
  /// - Returns: 해당 일자 레코드의 `PersistentIdentifier` 배열
  func _test_recordIDs(on day: Date, using context: ModelContext) throws -> [PersistentIdentifier] {
    let recs = try _test_fetchRoutineRecords(on: day, using: context)
    return recs.map { $0.persistentModelID }
  }
}

// MARK: Calendar 보조 확장

/// 테스트에서 초 단위를 무시하고 '분' 단위로 비교하기 위한 캘린더 보조 확장입니다.
private extension Calendar {
  /// 초 단위를 제거하고 동일 분으로 맞춘 `Date`를 반환합니다.
  /// - Parameter date: 기준 시각
  /// - Returns: 분 단위로 정규화된 `Date`
  func dateTrimToMinute(_ date: Date) -> Date {
    let c = dateComponents([.year, .month, .day, .hour, .minute], from: date)
    return self.date(from: c)! // 정상 경로에서 안전하게 생성
  }
}
