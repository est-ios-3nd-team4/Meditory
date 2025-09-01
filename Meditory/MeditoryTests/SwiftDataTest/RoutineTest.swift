import XCTest
import SwiftData
@testable import Meditory

final class RoutineTest: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var store: RoutineStore!

  // 테스트 설정도 비동기 작업을 포함하므로 async로 변경합니다.
  override func setUp() async throws {
    let schema = Schema([Routine.self, RoutineTime.self, RoutineRecord.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    // RoutineStore도 ModelContainer를 사용해 초기화합니다.
    store = RoutineStore(modelContainer: container)
  }

  override func tearDownWithError() throws {
    container = nil
    context = nil
    store = nil
  }

  /// Routine 생성 테스트
  func testCreateRoutine() async throws {
    // When (새로운 createRoutine 메서드 사용)
    _ = try await store.createRoutine(
      type: 1,
      displayName: "활성비타민D",
      desc: "",
      category: "비타민D",
      cycleType: 1,
      cycleValue: "0, 2, 4", // 월수금
      startDate: .now,
      memo: "아침 식사 후",
      usage: [],
      precautions: [],
      routineTimes: [],
      recommendedRoutineTimes: []
    )

    // Then
    let allIDs = await store.fetchAllRoutineIDs()
    XCTAssertEqual(allIDs.count, 1)
    
    let savedID = try XCTUnwrap(allIDs.first)
    let saved = try XCTUnwrap(context.model(for: savedID) as? Routine)
    
    XCTAssertEqual(saved.category, "비타민D")
    XCTAssertEqual(saved.cycleType, 1)
    XCTAssertEqual(saved.hasPush, true) // init 기본값
    XCTAssertEqual(saved.memo, "아침 식사 후")
  }

  /// Routine 삭제 테스트
  func testDeleteRoutine() async throws {
    // Given
    let routineID = try await store.createRoutine(
      type: 2,
      displayName: "항생제D",
      desc: nil,
      category: nil,
      cycleType: 2,
      cycleValue: "11",
      startDate: .now,
      memo: nil,
      usage: [],
      precautions: [],
      routineTimes: [],
      recommendedRoutineTimes: []
    )
    
    var allIDs = await store.fetchAllRoutineIDs()
    XCTAssertEqual(allIDs.count, 1)

    // When
    await store.deleteRoutine(id: routineID)

    // Then
    allIDs = await store.fetchAllRoutineIDs()
    XCTAssertEqual(allIDs.count, 0)
  }

  /// Routine 전체 삭제 테스트
  func testDeleteAllRoutines() async throws {
    // Given
    _ = try await store.createRoutine(
      type: 1, displayName: "A", desc: nil, category: nil, cycleType: 1, cycleValue: "0",
      startDate: .now, memo: nil, usage: [], precautions: [], routineTimes: [], recommendedRoutineTimes: []
    )
    
    _ = try await store.createRoutine(
      type: 2, displayName: "B", desc: nil, category: nil, cycleType: 2, cycleValue: "11",
      startDate: .now, memo: nil, usage: [], precautions: [], routineTimes: [], recommendedRoutineTimes: []
    )

    let allIDs = await store.fetchAllRoutineIDs()
    XCTAssertEqual(allIDs.count, 2)

    // When
    await store.deleteAllRoutines()

    // Then
    let remainingIDs = await store.fetchAllRoutineIDs()
    XCTAssertEqual(remainingIDs.count, 0)
  }


  /// RoutineTime 추가 및 조회 테스트
  func testAddAndFetchRoutineTime() async throws {
    // Given: Routine 1개 생성
    let routineID = try await store.createRoutine(
      type: 1, displayName: "오메가3", desc: nil, category: nil, cycleType: 1, cycleValue: "0, 2, 4",
      startDate: .now, memo: nil, usage: [], precautions: [], routineTimes: [], recommendedRoutineTimes: []
    )
    
    // When: RoutineTime 2개 추가
    let time1 = Date()
    let time2 = Date().addingTimeInterval(3600)
    await store.createRoutineTime(time: time1, pillsPerDose: 1, forRoutineID: routineID)
    await store.createRoutineTime(time: time2, pillsPerDose: 2, forRoutineID: routineID)

    // Then: Routine에 RoutineTime이 잘 연결됐는지 확인
    let refreshedRoutine = try XCTUnwrap(context.model(for: routineID) as? Routine)
    XCTAssertEqual(refreshedRoutine.routineTimes.count, 2)
    
    let times = refreshedRoutine.routineTimes.map(\.time)
    // Date는 정확한 비교가 어려우므로 timeIntervalSince1970으로 비교
    XCTAssertTrue(times.contains { abs($0.timeIntervalSince1970 - time1.timeIntervalSince1970) < 0.001 })
    XCTAssertTrue(times.contains { abs($0.timeIntervalSince1970 - time2.timeIntervalSince1970) < 0.001 })
  }

  /// RoutineRecord 추가 및 조회 테스트
  func testAddAndFetchRoutineRecord() async throws {
    // Given: Routine 1개 생성
    let routineID = try await store.createRoutine(
      type: 1, displayName: "종합비타민", desc: nil, category: nil, cycleType: 1, cycleValue: "1, 3, 5",
      startDate: .now, memo: nil, usage: [], precautions: [], routineTimes: [], recommendedRoutineTimes: []
    )

    // When: RoutineRecord 1개 추가
    let ts = Date()
    await store.createRoutineRecord(forRoutineID: routineID, timestamp: ts)

    // Then: RoutineRecord가 잘 추가됐는지 확인
    let fetch = FetchDescriptor<RoutineRecord>()
    let records = (try? context.fetch(fetch)) ?? []
    XCTAssertEqual(records.count, 1)
    
    let record = try XCTUnwrap(records.first)
    XCTAssertEqual(record.routine?.persistentModelID, routineID)
    XCTAssertEqual(record.timestamp.timeIntervalSince1970, ts.timeIntervalSince1970, accuracy: 1)
  }
}
