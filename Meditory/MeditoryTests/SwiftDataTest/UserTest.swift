//
//  UserTest.swift
//  MeditoryTests
//
//  Created by drfranken on 8/5/25.
//


import XCTest
import SwiftData
@testable import Meditory

final class UserTest: XCTestCase {

  var container: ModelContainer!
  var context: ModelContext!
  var store: UserStore!

  override func setUpWithError() throws {
    container = try ModelContainer(for: User.self, UserProfile.self)
    context = ModelContext(container)
    store = UserStore()
  }

  override func tearDownWithError() throws {
    container = nil
    context = nil
    store = nil
  }

  /// User 생성 테스트
  @MainActor
  func testCreateUserProfile() async throws {
    // Given: 유저를 먼저 생성하고 저장
    let user = User(name: "스티브잡스", birthDate: .now, gender: "남", displayName: "잡스형")
    context.insert(user)
    try context.save()
    store.currentUser = user

    // When: 프로필을 생성
    store.createUserProfile(height: 175.0, weight: 65.0, context: context)

    // Then: 프로필이 잘 추가됐는지 확인
    let profiles = user.userProfiles
    XCTAssertEqual(profiles.count, 1)
    let profile = profiles.first!
    XCTAssertEqual(profile.height, 175.0)
    XCTAssertEqual(profile.weight, 65.0)
    XCTAssertEqual(profile.user?.id, user.id)
  }

  /// UserStatus 테스트
  @MainActor
  func testCreateUserStatus() async throws {
    // Given: 유저를 먼저 생성하고 저장
    let user = User(name: "김여자", birthDate: .now, gender: "여", displayName: "여자킴")
    context.insert(user)
    try context.save()
    store.currentUser = user

    // When: 현재 진행 중인 상태 생성 (endDate 없음)
    store.createUserStatus(statusType: "모유수유중", startDate: .now, context: context)

    // When: 과거 종료된 상태 생성 (endDate 포함)
    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    let endedStatus = UserStatus(statusType: "임신중", startDate: thirtyDaysAgo, endDate: yesterday, user: user)
    user.userStatuses.append(endedStatus)
    context.insert(endedStatus)
    try context.save()

    // Then: 상태가 두 개 생성되었는지 확인
    let statuses = user.userStatuses
    XCTAssertEqual(statuses.count, 2)

    // 현재 진행 중인 상태 확인
    let currentStatus = statuses.first { $0.statusType == "모유수유중" }!
    XCTAssertNil(currentStatus.endDate)
    XCTAssertEqual(currentStatus.user?.id, user.id)

    // 과거 상태 확인
    let pastStatus = statuses.first { $0.statusType == "임신중" }!
    XCTAssertNotNil(pastStatus.endDate)
    XCTAssertEqual(pastStatus.endDate, yesterday)
    XCTAssertEqual(pastStatus.user?.id, user.id)
  }

  /// UserExtraInfo 테스트
  @MainActor
  func testCreateUserExtraInfo() async throws {
    // Given
    let user = User(name: "손오공", birthDate: .now, gender: "남", displayName: "원숭이")
    context.insert(user)
    try context.save()
    store.currentUser = user

    // 유저가 각 단계에서 아래 것들을 선택했다고 가정
    // 질병 4, 11 / 알러지 2, 5, 7 / 건강고민 1, 3
    let selectedDiseases = dataDisease.filter { ["disease_4", "disease_11"].contains($0.key) }
    let selectedAllergies = dataAllergy.filter { ["allergy_2", "allergy_5", "allergy_7"].contains($0.key) }
    let selectedConcerns = dataConcern.filter { ["concern_1", "concern_3"].contains($0.key) }

    // When
    let extraInfo = UserExtraInfo(
      disease: selectedDiseases,
      allergy: selectedAllergies,
      concern: selectedConcerns,
      user: user
    )
    store.addUserExtraInfo(extraInfo, context: context)

    // Then
    let infos = user.userExtraInfos
    XCTAssertEqual(infos.count, 1)
    let info = infos.first!
    XCTAssertEqual(info.disease.map(\.key).sorted(), ["disease_4", "disease_11"].sorted())
    XCTAssertEqual(info.allergy.map(\.key).sorted(), ["allergy_2", "allergy_5", "allergy_7"].sorted())
    XCTAssertEqual(info.concern.map(\.key).sorted(), ["concern_1", "concern_3"].sorted())
    XCTAssertEqual(info.user?.id, user.id)
  }


  /// ExtraInfo 참조데이터 리셋 테스트
  @MainActor
  func testResetExtraInfos() async throws {
    // 0. ExtraInfo가 없는 상태에서 reset
    store.resetExtraInfos(context: context)

    var all = try context.fetch(FetchDescriptor<ExtraInfo>())
    XCTAssertEqual(all.count, allInitialExtraInfos.count, "데이터 개수가 정확히 초기 스크립트 개수와 같아야 함")

    // 1. 일부러 임의 데이터 추가 후 reset
    let dummy = ExtraInfo(key: "disease_999", value: "더미", type: .disease)
    context.insert(dummy)
    try context.save()

    all = try context.fetch(FetchDescriptor<ExtraInfo>())
    XCTAssertTrue(all.contains(where: { $0.key == "disease_999" }), "더미 데이터가 추가되어 있어야 함")

    // 2. 다시 초기화
    store.resetExtraInfos(context: context)

    all = try context.fetch(FetchDescriptor<ExtraInfo>())
    XCTAssertEqual(all.count, allInitialExtraInfos.count, "초기화 후 개수는 항상 같아야 함")
    XCTAssertFalse(all.contains(where: { $0.key == "disease_999" }), "초기화 후 더미 데이터는 남아있으면 안 됨")

    // 3. 값 검증 (예시로 한두개만)
    let disease4 = all.first(where: { $0.key == "disease_4" })
    XCTAssertEqual(disease4?.value, "고지혈증")
    XCTAssertEqual(disease4?.type, .disease)
  }
}
