//
//  HomeRoutineManagerTests.swift
//  MeditoryTests
//
//  Created by Test on 2025/08/25
//

import XCTest
import SwiftData
@testable import Meditory

extension RoutineRecord: @unchecked @retroactive Sendable {}
extension Routine: @unchecked @retroactive Sendable {}
extension RoutineTime: @unchecked @retroactive Sendable {}

final class HomeRoutineManagerTests: XCTestCase {
  private var container: ModelContainer!
  private var context: ModelContext!
  private var sut: HomeRoutineManager!

  private let cal = Calendar.current

  /// h:m 시각(Date) 생성(초=0)
  private func clock(_ h: Int, _ m: Int) -> Date {
    var c = DateComponents(); c.hour = h; c.minute = m; c.second = 0
    return cal.date(from: c)!
  }

  /// 특정 날짜(day)의 연/월/일 + (h:m)의 시:분을 결합한 시각
  private func scheduled(on day: Date, h: Int, m: Int) -> Date {
    var t = cal.dateComponents([.hour, .minute, .second], from: clock(h, m))
    let d = cal.dateComponents([.year, .month, .day], from: day)
    t.year = d.year; t.month = d.month; t.day = d.day
    return cal.date(from: t)!
  }

  /// Routine + RoutineTime 삽입
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

  /// RoutineRecord 삽입
  @discardableResult
  private func insertRecord(for routine: Routine, at timestamp: Date) -> RoutineRecord {
    let rec = RoutineRecord(timestamp: timestamp, routine: routine)
    context.insert(rec)
    try? context.save()
    return rec
  }

  override func setUp() async throws {
    // SwiftData 인메모리 컨테이너 구성
    let schema = Schema([Routine.self, RoutineRecord.self, RoutineTime.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])

    context = ModelContext(container)

    // SUT – 동일 컨테이너 사용
    sut = HomeRoutineManager(modelContainer: container)
  }

  override func tearDown() {
    sut = nil
    context = nil
    container = nil
    super.tearDown()
  }


  /// 하루 범위 레코드 조회: 해당 일자만 반환되는지
  func test_FetchRoutineRecords_OnDay_FiltersByDay() async throws {
    let day = cal.startOfDay(for: Date())

    let r = insertRoutine(name: "멀티비타민", times: [(8, 0)])
    // day 내부 2건
    insertRecord(for: r, at: scheduled(on: day, h: 8, m: 0))
    insertRecord(for: r, at: scheduled(on: day, h: 20, m: 0))
    // 다른 날 1건
    let otherDay = cal.date(byAdding: .day, value: 1, to: day)!
    insertRecord(for: r, at: scheduled(on: otherDay, h: 8, m: 0))

    let recs = try await sut.fetchRoutineRecords(on: day)
    XCTAssertEqual(recs.count, 2)
    // 모두 day 범위 안이어야 함
    for rec in recs {
      XCTAssertTrue(cal.isDate(rec.timestamp, inSameDayAs: day))
    }
  }

  /// 월 범위 레코드 조회 + 정렬 확인
  func test_FetchRoutineRecords_InMonth_SortsAscending() async throws {
    // 이번 달 1일 00:00
    let baseMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
    let r = insertRoutine(name: "오메가3", times: [(9, 0)])

    // 이번 달 1일, 10일, 25일
    let d1 = scheduled(on: baseMonth, h: 9, m: 0)
    let d2 = scheduled(on: cal.date(byAdding: .day, value: 9, to: baseMonth)!, h: 9, m: 0)
    let d3 = scheduled(on: cal.date(byAdding: .day, value: 24, to: baseMonth)!, h: 9, m: 0)

    insertRecord(for: r, at: d2)
    insertRecord(for: r, at: d3)
    insertRecord(for: r, at: d1)

    let recs = try await sut.fetchRoutineRecords(inMonthOf: baseMonth)
    XCTAssertEqual(recs.map(\.timestamp), [d1, d2, d3])
  }

  /// isCompleted: 같은 루틴 & 같은 '분' 키로 매칭되는지
  func test_IsCompleted_MatchesByMinuteAndRoutine() async throws {
    let day = cal.startOfDay(for: Date())
    let r1 = insertRoutine(name: "비타민C", times: [(8, 0)])
    let r2 = insertRoutine(name: "프로바이오틱스", times: [(8, 0)])

    let t = scheduled(on: day, h: 8, m: 30)

    // r1에만 레코드 기록 (같은 분)
    insertRecord(for: r1, at: t)

    // r1은 true, r2는 false 이어야 함
    let r1Done = await sut.isCompleted(routineID: r1.persistentModelID, at: t)
    let r2Done = await sut.isCompleted(routineID: r2.persistentModelID, at: t)

    XCTAssertTrue(r1Done)
    XCTAssertFalse(r2Done)

    // '초'가 달라도 같은 분이면 true
    let tSameMinute = t.addingTimeInterval(10) // +10초
    let r1DoneSameMinute = await sut.isCompleted(routineID: r1.persistentModelID, at: tSameMinute)
    XCTAssertTrue(r1DoneSameMinute)
  }

  /// delete(recordID:)가 해당 레코드만 제거하는지
  func test_DeleteRecord_RemovesOnlyTarget() async throws {
    let day = cal.startOfDay(for: Date())
    let r = insertRoutine(name: "마그네슘", times: [(22, 0)])

    let rec1 = insertRecord(for: r, at: scheduled(on: day, h: 22, m: 0))
    let rec2 = insertRecord(for: r, at: scheduled(on: day, h: 8, m: 0))

    // 삭제
    await sut.delete(recordID: rec1.persistentModelID)

    let ids = try await sut._test_recordIDs(on: day)
    XCTAssertEqual(ids.count, 1)
    XCTAssertEqual(ids.first, rec2.persistentModelID)
  }
}

extension HomeRoutineManager {
  func _test_recordIDs(on day: Date) async throws -> [PersistentIdentifier] {
    let recs = try fetchRoutineRecords(on: day)
    return recs.map { $0.persistentModelID }
  }
}
