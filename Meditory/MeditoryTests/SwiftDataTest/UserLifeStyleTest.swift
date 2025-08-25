//
//  UserLifeStyleTest.swift
//  MeditoryTests
//
//  Created by 윤혜주 on 8/13/25.
//

import XCTest
import SwiftData
@testable import Meditory

@MainActor
final class UserLifeStyleTest: XCTestCase {
  private var container: ModelContainer!
  private var context: ModelContext!
  private var user: User!
  private var store: UserLifeStyleStore!

  override func setUpWithError() throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(
      for: User.self, UserLifeStyle.self,
      configurations: config
    )
    context = ModelContext(container)

    user = User(name: "테스터", birthDate: .now, gender: "여", displayName: "사람")
    context.insert(user)
    try context.save()

    store = UserLifeStyleStore()
    store.currentUser = user
  }

  override func tearDownWithError() throws {
    store = nil
    user = nil
    context = nil
    container = nil
  }

  /// 현재 User에 매핑된 라이프사이클을 조회/생성
  @discardableResult
  private func fetchOrCreate() -> UserLifeStyle {
    guard let lifeStyle = store.fetchOrCreateLifestyle(context: context) else {
      XCTFail("fetchOrCreateLifestyle returned nil")
      fatalError()
    }
    return lifeStyle
  }

  /// 오늘 날짜 기준 시:분만 바꾼 Date 생성
  private func makeDate(_ h: Int, _ m: Int) -> Date {
    var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    comps.hour = h
    comps.minute = m
    return Calendar.current.date(from: comps)!
  }

  /// currentUser가 nil이면 생성/조회하지 말아야 함
  func testStore_returnsNilWhenCurrentUserIsNil() throws {
    // Given: currentUser가 nil
    store.currentUser = nil

    // When: fetchOrCreateLifestyle 호출
    let lifeStyle = store.fetchOrCreateLifestyle(context: context)

    // Then: nil을 반환해야 함
    XCTAssertNil(lifeStyle)
  }

  /// 없으면 기본값으로 생성되는지
  func testFetchOrCreate_createWhenMissing() throws {
    // Given: DB에 UserLifeCycle이 없음

    // When: 최초 fetchOrCreate 호출
    let lifeStyle = fetchOrCreate()

    // Then: 새 레코드가 생성되고 기본값이 세팅됨
    XCTAssertEqual(lifeStyle.user?.id, user.id)
    XCTAssertEqual(lifeStyle.wakeTime, "07:00")
    XCTAssertEqual(lifeStyle.sleepTime, "23:30")
    XCTAssertEqual(lifeStyle.lunch, "12:00")
    XCTAssertEqual(lifeStyle.dinner, "19:00")
    XCTAssertEqual(lifeStyle.lunch, "12:30")
    XCTAssertEqual(lifeStyle.dinner, "19:30")
  }

  /// 이미 있으면 같은 레코드를 반환해야 함
  func testFetchOrCreate_fetchWhenExisting() throws {
    // Given: 기존 레코드가 존재
    var lifeStyle = fetchOrCreate()
    lifeStyle.wakeTime = "08:00"
    try context.save()

    // When: 다시 fetchOrCreate 호출
    lifeStyle = fetchOrCreate()

    // Then: 동일 레코드가 반환되고 값이 유지됨
    XCTAssertEqual(lifeStyle.wakeTime, "08:00")
  }

  /// 같은 유저로 여러 번 호출해도 중복 생성 금지(1:1 보장)
  func testFetchOrCreate_noDuplicateRecords() throws {
    // Given: 동일 user 대상으로
    _ = fetchOrCreate()

    // When: 여러 번 fetchOrCreate 호출
    _ = fetchOrCreate()
    _ = fetchOrCreate()
    let all = try context.fetch(FetchDescriptor<UserLifeStyle>())

    // Then: 레코드는 1개만 존재
    XCTAssertEqual(all.count, 1)
  }

  /// 같은 유저로 다시 호출하면 동일 레코드(ID 동일)
  func testFetchOrCreate_returnsSameRecordForSameUser() throws {
    // Given: 동일 user
    let a = fetchOrCreate()

    // When: 다시 fetchOrCreate 호출
    let b = fetchOrCreate()

    // Then: 같은 ID의 레코드
    XCTAssertEqual(a.id, b.id)
  }

  /// 문자열 기반 업데이트가 저장되는지
  func testSetLifestyleTimes_persistsStrings() throws {
    // Given: 레코드 1개 존재
    let lifeStyle = fetchOrCreate()

    // When: 문자열 파라미터로 업데이트
    store.setLifestyleTimes(
      lifeStyle,
      context: context,
      breakfast: "08:00",
      lunch: "12:30",
      dinner: "19:10"
    )

    // Then: 값이 그대로 저장됨
    let fetched = fetchOrCreate()
    XCTAssertEqual(fetched.breakfast, "08:00")
    XCTAssertEqual(fetched.lunch, "12:30")
    XCTAssertEqual(fetched.dinner, "19:10")
  }

  /// 일부 파라미터만 전달했을 때, 나머지는 보존되어야 함
  func testSetLifestyleTimes_partialUpdateKeepsExisting() throws {
    // Given: 기존에 lunchWeekday = "12:10" 저장
    let lifeStyle = fetchOrCreate()
    lifeStyle.lunch = "12:10"
    try context.save()

    // When: 일부만 업데이트(lunchWeekday는 nil → 보존)
    store.setLifestyleTimes(
      lifeStyle,
      context: context,
      breakfast: "08:05",
      lunch: nil,
      dinner: "19:20"
    )

    // Then: 지정 필드만 바뀌고 나머지 보존
    let again = fetchOrCreate()
    XCTAssertEqual(again.breakfast, "08:05")
    XCTAssertEqual(again.lunch, "12:10")
    XCTAssertEqual(again.dinner, "19:20")
  }

  /// Date 기반 업데이트가 저장되는지 (Date → "HH:mm" 제로패딩 확인)
  func testSetLifestyleTimes_withDates() throws {
    // Given: 레코드 1개 존재
    let lifeStyle = fetchOrCreate()

    // When: Date 파라미터로 업데이트
    store.setLifestyleTimesDate(
      lifeStyle,
      context: context,
      breakfast: makeDate(7, 50),
      lunch: makeDate(13, 5)
    )

    // Then: "HH:mm" 제로패딩으로 저장
    let re = fetchOrCreate()
    XCTAssertEqual(re.breakfast, "07:50")
    XCTAssertEqual(re.lunch, "13:05")
  }

  /// Date → "HH:mm" 변환이 09:07 형태로 제로패딩되는지
  func testSetLifestyleTimesDate_zeroPadding() throws {
    // Given: 레코드 1개 존재
    let lifeStyle = fetchOrCreate()

    // When: 9:07을 Date로 설정
    store.setLifestyleTimesDate(lifeStyle, context: context,
                                wakeTime: makeDate(9, 7))

    // Then: "09:07"로 저장
    let again = fetchOrCreate()
    XCTAssertEqual(again.wakeTime, "09:07")
  }

  /// 주말 오버라이드가 정상적으로 반영되는지
  func testWeekendOverrides_withStrings() throws {
    // Given: 레코드 1개 존재
    let lifeStyle = fetchOrCreate()

    // When: 주말 전용 필드 업데이트
    store.setLifestyleTimes(
      lifeStyle,
      context: context,
      wakeTime: "09:30",
      dinner: "19:45"
    )

    // Then: 주말 오버라이드가 반영됨
    let again = fetchOrCreate()
    XCTAssertEqual(again.wakeTime, "09:30")
    XCTAssertEqual(again.dinner, "19:45")
  }
}
