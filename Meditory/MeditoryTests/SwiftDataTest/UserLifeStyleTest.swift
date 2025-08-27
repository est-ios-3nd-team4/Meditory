//
//  UserLifeStyleTest.swift
//  MeditoryTests
//
//  Created by 윤혜주 on 8/13/25.
//

import XCTest
import SwiftData
@testable import Meditory

final class UserLifeStyleTest: XCTestCase {
  private var container: ModelContainer!
  private var context: ModelContext!
  private var userStore: UserStore! // User를 생성하고 관리할 UserStore
  private var store: UserLifeStyleStore!
  private var userID: PersistentIdentifier! // User 객체 대신 ID를 저장

  // 테스트 설정도 비동기 작업을 포함하므로 async로 변경합니다.
  override func setUp() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(
      for: User.self, UserLifeStyle.self,
      configurations: config
    )
    context = ModelContext(container)

    // UserStore와 UserLifeStyleStore를 동일한 컨테이너로 초기화합니다.
    userStore = UserStore(modelContainer: container)
    store = UserLifeStyleStore(modelContainer: container)

    // User를 UserStore 액터를 통해 생성합니다.
    userID = await userStore.addUser(
      User(name: "테스터", birthDate: .now, gender: "여", displayName: "사람")
    )
    
    // 다른 액터 및 시스템이 데이터베이스 저장을 처리할 시간을 주기 위해 잠시 실행을 양보합니다.
    // 이것이 테스트 환경의 경합 조건을 해결하는 핵심입니다.
    await Task.yield()
  }

  override func tearDownWithError() throws {
    store = nil
    userStore = nil
    context = nil
    container = nil
  }

  /// 오늘 날짜 기준 시:분만 바꾼 Date 생성
  private func makeDate(_ h: Int, _ m: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour = h
    comps.minute = m
    return Calendar.current.date(from: comps)!
  }

  /// 잘못된 ID를 전달하면 nil을 반환해야 함
  func testStore_returnsNilWhenUserIDIsInvalid() async throws {
    // Given: 존재하지 않는 User ID
    let fakeUserID = userID!
    await userStore.deleteUser(id: fakeUserID) // UserStore를 통해 안전하게 삭제
    await Task.yield() // 삭제 작업이 반영될 시간을 줍니다.

    // When: fetchOrCreateLifestyleID 호출
    let lifeStyleID = await store.fetchOrCreateLifestyleID(for: fakeUserID)

    // Then: nil을 반환해야 함
    XCTAssertNil(lifeStyleID)
  }

  /// 없으면 기본값으로 생성되는지
  func testFetchOrCreate_createWhenMissing() async throws {
    // When: 최초 fetchOrCreate 호출
    let lifeStyleID = await store.fetchOrCreateLifestyleID(for: userID)
    let unwrappedID = try XCTUnwrap(lifeStyleID)
    let lifeStyle = try XCTUnwrap(context.model(for: unwrappedID) as? UserLifeStyle)

    // Then: 새 레코드가 생성되고 기본값이 세팅됨
    let user = try XCTUnwrap(context.model(for: userID) as? User)
    XCTAssertEqual(lifeStyle.user?.id, user.id)
    XCTAssertEqual(lifeStyle.wakeTime, "07:00")
    XCTAssertEqual(lifeStyle.sleepTime, "23:30")
    XCTAssertEqual(lifeStyle.lunch, "12:30")
    XCTAssertEqual(lifeStyle.dinner, "19:30")
  }

  /// 이미 있으면 같은 레코드를 반환해야 함
  func testFetchOrCreate_fetchWhenExisting() async throws {
    // Given: 기존 레코드가 존재하고 값이 수정됨
    let initialID = await store.fetchOrCreateLifestyleID(for: userID)
    let unwrappedID = try XCTUnwrap(initialID)
    // 데이터를 수정할 때도 반드시 액터를 통해야 합니다.
    await store.setLifestyleTimes(id: unwrappedID, wakeTime: "08:00")
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // When: 다시 fetchOrCreate 호출
    let fetchedID = await store.fetchOrCreateLifestyleID(for: userID)
    // Then: 동일 레코드가 반환되고 값이 유지됨 (context를 통해 검증)
    let fetchedLifestyle = try XCTUnwrap(context.model(for: try XCTUnwrap(fetchedID)) as? UserLifeStyle)
    XCTAssertEqual(fetchedLifestyle.wakeTime, "08:00")
  }

  /// 같은 유저로 여러 번 호출해도 중복 생성 금지(1:1 보장)
  func testFetchOrCreate_noDuplicateRecords() async throws {
    // When: 여러 번 fetchOrCreate 호출
    _ = await store.fetchOrCreateLifestyleID(for: userID)
    _ = await store.fetchOrCreateLifestyleID(for: userID)
    
    // Then: 레코드는 1개만 존재
    let all = try context.fetch(FetchDescriptor<UserLifeStyle>())
    XCTAssertEqual(all.count, 1)
  }

  /// 같은 유저로 다시 호출하면 동일 레코드(ID 동일)
  func testFetchOrCreate_returnsSameRecordForSameUser() async throws {
    // When: fetchOrCreate를 두 번 호출
    let id1 = await store.fetchOrCreateLifestyleID(for: userID)
    let id2 = await store.fetchOrCreateLifestyleID(for: userID)

    // Then: 같은 ID의 레코드
    XCTAssertEqual(id1, id2)
  }

  /// 문자열 기반 업데이트가 저장되는지
  func testSetLifestyleTimes_persistsStrings() async throws {
    // Given: 레코드 1개 존재
    let lifeStyleIDResult = await store.fetchOrCreateLifestyleID(for: userID)
    let lifeStyleID = try XCTUnwrap(lifeStyleIDResult)

    // When: 문자열 파라미터로 업데이트
    await store.setLifestyleTimes(
      id: lifeStyleID,
      breakfast: "08:00",
      lunch: "12:30",
      dinner: "19:10"
    )
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // Then: 값이 그대로 저장됨 (context를 통해 검증)
    let fetched = try XCTUnwrap(context.model(for: lifeStyleID) as? UserLifeStyle)
    XCTAssertEqual(fetched.breakfast, "08:00")
    XCTAssertEqual(fetched.lunch, "12:30")
    XCTAssertEqual(fetched.dinner, "19:10")
  }

  /// 일부 파라미터만 전달했을 때, 나머지는 보존되어야 함
  func testSetLifestyleTimes_partialUpdateKeepsExisting() async throws {
    // Given: 액터를 통해 lunch = "12:10"을 먼저 저장
    let lifeStyleIDResult = await store.fetchOrCreateLifestyleID(for: userID)
    let lifeStyleID = try XCTUnwrap(lifeStyleIDResult)
    await store.setLifestyleTimes(id: lifeStyleID, lunch: "12:10")
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // When: 일부만 업데이트(lunch는 nil → 보존)
    await store.setLifestyleTimes(
      id: lifeStyleID,
      breakfast: "08:05",
      lunch: nil,
      dinner: "19:20"
    )
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // Then: 지정 필드만 바뀌고 나머지 보존 (context를 통해 검증)
    let again = try XCTUnwrap(context.model(for: lifeStyleID) as? UserLifeStyle)
    XCTAssertEqual(again.breakfast, "08:05")
    XCTAssertEqual(again.lunch, "12:10")
    XCTAssertEqual(again.dinner, "19:20")
  }

  /// Date 기반 업데이트가 저장되는지 (Date → "HH:mm" 제로패딩 확인)
  func testSetLifestyleTimes_withDates() async throws {
    // Given: 레코드 1개 존재
    let lifeStyleIDResult = await store.fetchOrCreateLifestyleID(for: userID)
    let lifeStyleID = try XCTUnwrap(lifeStyleIDResult)

    // When: Date 파라미터로 업데이트
    try await store.setLifestyleTimesDate(
      id: lifeStyleID,
      breakfast: makeDate(7, 50),
      lunch: makeDate(13, 5)
    )
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // Then: "HH:mm" 제로패딩으로 저장 (context를 통해 검증)
    let re = try XCTUnwrap(context.model(for: lifeStyleID) as? UserLifeStyle)
    XCTAssertEqual(re.breakfast, "07:50")
    XCTAssertEqual(re.lunch, "13:05")
  }

  /// Date → "HH:mm" 변환이 09:07 형태로 제로패딩되는지
  func testSetLifestyleTimesDate_zeroPadding() async throws {
    // Given: 레코드 1개 존재
    let lifeStyleIDResult = await store.fetchOrCreateLifestyleID(for: userID)
    let lifeStyleID = try XCTUnwrap(lifeStyleIDResult)

    // When: 9:07을 Date로 설정
    try await store.setLifestyleTimesDate(id: lifeStyleID, wakeTime: makeDate(9, 7))
    await Task.yield() // 수정 작업이 반영될 시간을 줍니다.

    // Then: "09:07"로 저장 (context를 통해 검증)
    let again = try XCTUnwrap(context.model(for: lifeStyleID) as? UserLifeStyle)
    XCTAssertEqual(again.wakeTime, "09:07")
  }
}
