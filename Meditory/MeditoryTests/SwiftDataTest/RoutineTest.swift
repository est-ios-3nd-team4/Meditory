import XCTest
import SwiftData
@testable import Meditory

final class RoutineTest: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var store: RoutineStore!

  override func setUpWithError() throws {
    let schema = Schema([Routine.self, RoutineTime.self, RoutineRecord.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    store = RoutineStore()
  }

  override func tearDownWithError() throws {
    container = nil
    context = nil
    store = nil
  }

  /// Routine 생성 테스트
  @MainActor
  func testCreateRoutine() async throws {
    // When (RoutineStore 사용)
    store.createRoutine(
      type: 1,
      name: "비타민D",
      cycleType: 1,
      cycleValue: [0, 2, 4], // 월수금
      startDate: .now,
      timesPerDay: 2,
      pillsPerDose: 1,
      memo: "아침 식사 후",
      hasPush: true,
      imageData: nil,
      productName: "써큐텐D",
      productDescription: "활성비타민D",
      notWith: nil,
      whenToTake: "식후",
      context: context
    )

    // Then
    let all = store.fetchAllRoutines(context: context)
    XCTAssertEqual(all.count, 1)
    let saved = all.first!
    XCTAssertEqual(saved.name, "비타민D")
    XCTAssertEqual(saved.cycleType, 1)
    XCTAssertEqual(saved.timesPerDay, 2)
    XCTAssertEqual(saved.hasPush, true)
    XCTAssertEqual(saved.memo, "아침 식사 후")
  }

  /// Routine 삭제 테스트
  @MainActor
  func testDeleteRoutine() async throws {
    // Given
    store.createRoutine(
      type: 2,
      name: "항생제",
      cycleType: 2,
      cycleValue: [11],
      startDate: .now,
      timesPerDay: 3,
      pillsPerDose: 1,
      hasPush: false,
      context: context
    )
    var all = store.fetchAllRoutines(context: context)
    XCTAssertEqual(all.count, 1)
    let target = all.first!

    // When
    store.deleteRoutine(target, context: context)

    // Then
    all = store.fetchAllRoutines(context: context)
    XCTAssertEqual(all.count, 0)
  }

  /// Routine 전체 삭제 테스트
  @MainActor
  func testDeleteAllRoutines() async throws {
    // Given
    store.createRoutine(
      type: 1,
      name: "A",
      cycleType: 1,
      cycleValue: [0],
      startDate: .now,
      timesPerDay: 1,
      pillsPerDose: 1,
      hasPush: false,
      context: context
    )
    store.createRoutine(
      type: 2,
      name: "B",
      cycleType: 2,
      cycleValue: [11],
      startDate: .now,
      timesPerDay: 1,
      pillsPerDose: 1,
      hasPush: false,
      context: context
    )

    let all = store.fetchAllRoutines(context: context)
    XCTAssertEqual(all.count, 2)

    // When
    store.deleteAllRoutines(context: context)

    // Then
    let remain = store.fetchAllRoutines(context: context)
    XCTAssertEqual(remain.count, 0)
  }


  /// RoutineTime 추가 및 조회 테스트
  @MainActor
  func testAddAndFetchRoutineTime() async throws {
    // Given: Routine 1개 생성
    store.createRoutine(
      type: 1,
      name: "오메가3",
      cycleType: 1,
      cycleValue: [0, 2, 4],
      startDate: .now,
      timesPerDay: 1,
      pillsPerDose: 1,
      hasPush: false,
      context: context
    )
    let routine = store.fetchAllRoutines(context: context).first!
    // When: RoutineTime 2개 추가
    let time1 = Date()
    let time2 = Date().addingTimeInterval(3600)
    store.createRoutineTime(time: time1, for: routine, context: context)
    store.createRoutineTime(time: time2, for: routine, context: context)

    // Then: Routine에 RoutineTime이 잘 연결됐는지 확인
    let refreshedRoutine = store.fetchAllRoutines(context: context).first!
    XCTAssertEqual(refreshedRoutine.routineTimes.count, 2)
    let times = refreshedRoutine.routineTimes.map(\.time)
    XCTAssertTrue(times.contains(time1))
    XCTAssertTrue(times.contains(time2))
  }

  /// RoutineRecord 추가 및 조회 테스트
  @MainActor
  func testAddAndFetchRoutineRecord() async throws {
    // Given: Routine 1개 생성
    store.createRoutine(
      type: 1,
      name: "종합비타민",
      cycleType: 1,
      cycleValue: [1, 3, 5],
      startDate: .now,
      timesPerDay: 1,
      pillsPerDose: 1,
      hasPush: true,
      context: context
    )
    let routine = store.fetchAllRoutines(context: context).first!

    // When: RoutineRecord 1개 추가
    let ts = Date()
    store.createRoutineRecord(for: routine, timestamp: ts, context: context)

    // Then: RoutineRecord가 잘 추가됐는지 확인
    let refreshedRoutine = store.fetchAllRoutines(context: context).first!
    // routine.routineRecords가 있으면 거기로, 없으면 fetch로
    let fetch = FetchDescriptor<RoutineRecord>()
    let records = (try? context.fetch(fetch)) ?? []
    XCTAssertEqual(records.count, 1)
    let record = records.first!
    XCTAssertEqual(record.routine?.id, refreshedRoutine.id)
    XCTAssertEqual(record.timestamp.timeIntervalSince1970, ts.timeIntervalSince1970, accuracy: 1)
  }
}
