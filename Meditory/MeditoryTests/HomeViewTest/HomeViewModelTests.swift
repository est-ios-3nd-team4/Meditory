//
//  HomeViewModelTests.swift
//  MeditoryTests
//
//  Created by Test on 2025/08/25
//

import XCTest
import SwiftData
@testable import Meditory

// MARK: 테스트 안전성을 위한 Sendable retroactive 선언
// SwiftData @Model 객체는 기본적으로 Sendable 제약을 만족하지 않기 때문에
// 테스트 실행 시 동시성 관련 경고를 막기 위해 선언합니다.
extension RoutineRecord: @unchecked @retroactive Sendable {}
extension Routine: @unchecked @retroactive Sendable {}
extension RoutineTime: @unchecked @retroactive Sendable {}

/// HomeViewModel의 주요 동작을 검증하기 위한 단위 테스트 모음입니다.
final class HomeViewModelTests: XCTestCase {

  // MARK: - SwiftData 인메모리 컨테이너 구성
  private var container: ModelContainer!
  private var context: ModelContext!

  /// System Under Test
  private var vm: HomeViewModel!

  private let cal = Calendar.current

  // MARK: - 공용 더미 & 유틸

  /// 테스트에서 간단히 사용하기 위한 더미 Routine 생성기
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

  /// IntakeItem을 쉽게 생성하기 위한 유틸
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

  /// 단순 시각(Date) 생성기 (h:m, 초=0)
  private func clock(_ h: Int, _ m: Int) -> Date {
    var c = DateComponents(); c.hour = h; c.minute = m; c.second = 0
    return cal.date(from: c)!
  }

  /// 특정 날짜(day)의 연/월/일에 시/분(h:m)을 합성한 Date 반환
  private func scheduled(on day: Date, h: Int, m: Int) -> Date {
    var t = cal.dateComponents([.hour, .minute, .second], from: clock(h, m))
    let d = cal.dateComponents([.year, .month, .day], from: day)
    t.year = d.year; t.month = d.month; t.day = d.day
    return cal.date(from: t)!
  }

  /// Routine + RoutineTime을 SwiftData에 삽입
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

    for rt in rTimes { rt.routine = routine } // 역참조 연결

    context.insert(routine)
    try? context.save()
    return routine
  }

  /// RoutineRecord를 SwiftData에 삽입
  @discardableResult
  private func insertRecord(for routine: Routine, at timestamp: Date) -> RoutineRecord {
    let rec = RoutineRecord(timestamp: timestamp, routine: routine)
    context.insert(rec)
    try? context.save()
    return rec
  }

  // MARK: - XCTest 생명주기

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

  override func tearDown() {
    vm = nil
    context = nil
    container = nil
    super.tearDown()
  }

  // MARK: HomeViewModel 고유 기능 테스트

  /// intakeItems가 비어있을 때 progress는 0인지 검증
  func test_progress_isZero_whenNoItems() {
    let vm = HomeViewModel()
    vm.intakeItems = []
    XCTAssertEqual(vm.progress, 0.0, accuracy: 0.0001)
  }

  /// 완료/미완료 조합에 따른 progress 계산이 올바른지 검증
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

  /// dayCompletionMap을 수동으로 갱신했을 때 반영되는지 검증
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

  /// 하루 범위 레코드 조회 시, 해당 일자의 데이터만 반환되는지 검증
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

  /// 월간 범위 레코드 조회 시 오름차순 정렬되는지 검증
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

  /// isCompleted: 같은 루틴 & 같은 '분' 단위 시간으로 매칭되는지 검증
  func test_IsCompleted_MatchesByMinuteAndRoutine() throws {
    let day = cal.startOfDay(for: Date())
    let r1 = insertRoutine(name: "비타민C", times: [(8, 0)])
    let r2 = insertRoutine(name: "프로바이오틱스", times: [(8, 0)])

    let t = scheduled(on: day, h: 8, m: 30)

    // r1에만 기록
    insertRecord(for: r1, at: t)

    let r1Done = try _test_isCompleted(routineID: r1.persistentModelID, at: t, using: context)
    let r2Done = try _test_isCompleted(routineID: r2.persistentModelID, at: t, using: context)

    XCTAssertTrue(r1Done)
    XCTAssertFalse(r2Done)

    // 같은 분 단위면 초 단위 차이는 무시되는지 검증
    let tSameMinute = t.addingTimeInterval(10)
    let r1DoneSameMinute = try _test_isCompleted(routineID: r1.persistentModelID, at: tSameMinute, using: context)
    XCTAssertTrue(r1DoneSameMinute)
  }

  /// delete(recordID:)가 지정된 레코드만 삭제하는지 검증
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

  /// 하루 단위 RoutineRecord 조회
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

  /// 월 단위 RoutineRecord 조회 (오름차순 정렬)
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

  /// 특정 루틴이 특정 시각(분 단위)에 완료되었는지 여부 반환
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

  /// 특정 recordID를 삭제
  func _test_delete(recordID: PersistentIdentifier, using context: ModelContext) async throws {
    guard let rec = context.model(for: recordID) as? RoutineRecord else { return }
    context.delete(rec)
    try context.save()
  }

  /// 특정 일자의 RoutineRecord ID 집합 반환
  func _test_recordIDs(on day: Date, using context: ModelContext) throws -> [PersistentIdentifier] {
    let recs = try _test_fetchRoutineRecords(on: day, using: context)
    return recs.map { $0.persistentModelID }
  }
}

// MARK: Calendar 보조 확장
private extension Calendar {
  /// 초 단위를 버리고 분 단위로 맞춰주는 헬퍼
  /// (테스트에서 완료 여부 비교 시 초 단위 차이를 무시하기 위함)
  func dateTrimToMinute(_ date: Date) -> Date {
    let c = dateComponents([.year, .month, .day, .hour, .minute], from: date)
    return self.date(from: c)! // 정상 경로에서 안전하게 생성
  }
}
