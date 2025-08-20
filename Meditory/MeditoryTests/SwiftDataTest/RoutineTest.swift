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
    store.addRoutine(
      Routine(
        type: 1,
        displayName: "활성비타민D",
        desc: "",
        category: "비타민D",
        cycleType: 1,
        cycleValue: "0, 2, 4", // 월수금
        startDate: .now,
        memo: "아침 식사 후",
        hasPush: true,
        imageData: nil
      ),
      context: context
    )

    // Then
    let all = store.fetchAllRoutines(context: context)
    XCTAssertEqual(all.count, 1)
    let saved = all.first!
    XCTAssertEqual(saved.category, "비타민D")
    XCTAssertEqual(saved.cycleType, 1)
    XCTAssertEqual(saved.hasPush, true)
    XCTAssertEqual(saved.memo, "아침 식사 후")
  }

  /// Routine 삭제 테스트
  @MainActor
  func testDeleteRoutine() async throws {
    // Given
    store.addRoutine(
      Routine(
        type: 2,
        displayName: "항생제D",
        cycleType: 2,
        cycleValue: "11",
        startDate: .now,
        hasPush: true,
        imageData: nil
      ),
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
    store
      .addRoutine(Routine(
      type: 1,
      displayName: "A",
      cycleType: 1,
      cycleValue: "0",
      startDate: .now,
      hasPush: true,
      imageData: nil
    ), context: context)
    
    store.addRoutine(
      Routine(
        type: 2,
        displayName: "B",
        cycleType: 2,
        cycleValue: "11",
        startDate: .now,
        hasPush: true,
        imageData: nil
      ),
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
    store.addRoutine(
      Routine(
        type: 1,
        displayName: "오메가3",
        cycleType: 1,
        cycleValue: "0, 2, 4",
        startDate: .now,
        hasPush: false,
        imageData: nil
      ),
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
    store.addRoutine(
      Routine(
        type: 1,
        displayName: "종합비타민",
        cycleType: 1,
        cycleValue: "1, 3, 5",
        startDate: .now,
        imageData: nil
      ),
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
