//
//  OnboardingUnitTest.swift
//  MeditoryTests
//
//  Created by hyunsic on 8/22/25.
//

import SwiftData
import SwiftUI
import XCTest

@testable import Meditory

final class OnboardingUnitTest: XCTestCase {

  var container: ModelContainer!
  var modelContext: ModelContext!
  var userStore: UserStore!
  var sut: OnboardingViewModel!

  override func setUpWithError() throws {
    let schema = Schema([User.self, UserExtraInfo.self, UserProfile.self, UserStatus.self, ExtraInfo.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    modelContext = ModelContext(container)
    userStore = UserStore(modelContainer: container)
    sut = OnboardingViewModel(userStore: userStore)
  }

  override func tearDownWithError() throws {
    container = nil
    userStore = nil
    sut = nil
  }

  ///각필드의 유효성 검사
  func test_eachField_validation() async throws {
    let exp = expectation(description: "대기 필요")

    //given
    sut.updateContent(.height, context: "170")
    sut.updateContent(.weight, context: "179")
    sut.updateContent(.name, context: "james")
    sut.updateContent(.birthDate, context: "2025")

    //when
    sut.validate(.height)
    sut.validate(.weight)
    sut.validate(.name)
    sut.validate(.birthDate)
    
    Task {
      await MainActor.run {
        exp.fulfill()
      }
    }
    await fulfillment(of: [exp],timeout: 1.0)

    //then
    let heightResult = try XCTUnwrap(sut.fieldStates[.height]?.isValid)
    let weightResult = try XCTUnwrap(sut.fieldStates[.weight]?.isValid)
    let nameResult = try XCTUnwrap(sut.fieldStates[.name]?.isValid)
    let bodResult = try XCTUnwrap(sut.fieldStates[.birthDate]?.isValid)

    XCTAssertTrue(heightResult, "키가 유효하지 않습니다")
    XCTAssertTrue(weightResult, "체중이 유효하지 않습니다")
    XCTAssertTrue(nameResult, "이름이 유효하지 않습니다")
    XCTAssertTrue(bodResult, "생년월일이 유효하지 않습니다")
  }

  ///기본 가입정보들 중 하나라도 유효성 검증을 통과하지 못했을 경우 다음 버튼이 활성화되면 안된다
  func test_nextButton_shouldntactivate() async throws {
    //given

    sut.updateContent(.name, context: "James")
    sut.updateContent(.weight, context: "155.53")
    sut.updateContent(.height, context: "150")
    sut.updateContent(.birthDate, context: "1999")

    //when
    sut.validateAllField()

    //then
    try await Task.sleep(nanoseconds: 2_000_000_000)
    XCTAssertTrue(sut.isNextButtonOn,"다음 버튼이 활성화되어있지 않습니다.")
  }

  ///유저가 남성일 경우 회원가입 완료 후 유저상태에서 여성관련 옵션들이 존재하면 안된다
  func test_userStoreSelectionSet_noWomanOptionFound() async throws {
    //given
    sut.name = "James"
    sut.gender = "남성"
    sut.birthDate = Date.now
    sut.height = 177
    sut.weight = 70

    let concernSets: Set<QuestionModel> = [
      .init(code: "concern_6", title: "간 질환", type: .concern),
      .init(code: "concern_11", title: "갑상선 질환", type: .concern),
      .init(code: "concern_16", title: "비만", type: .concern),
    ]
    let diseasesSet: Set<QuestionModel> = [
      .init(code: "disease_4", title: "뇌 질환", type: .disease, image: "icon_brain"),
      .init(code: "disease_8", title: "폐 질환", type: .disease, image: "icon_bone"),
      .init(code: "disease_11", title: "비만 질환", type: .disease, image: "icon_weight"),
    ]
    let allergySets: Set<QuestionModel> = [
      .init(
        code: "allergy_1",
        title: "견과류·씨앗류",
        type: .allergy,

        subtitle: "땅콩, 호두, 아몬드, 캐슈넛, 피스타치오, 헤이즐넛 등",
        symptom: "입술·혀 부종, 두드러기, 호흡곤란, 아나필락시스",
        treatment: "즉시 섭취 중단, 에피네프린 사용, 응급실 이동",
        toggleImage: .name(base: "nuts_seeds")
      ),
      .init(
        code: "allergy_4",
        title: "해산물",
        type: .allergy,
        subtitle: "생선, 갑각류, 연체류, 조개류 등",
        symptom: "입·목 가려움, 호흡곤란, 혈압 저하",
        treatment: "섭취·조리 환경 회피, 에피네프린 준비",
        toggleImage: .name(base: "seafood")
      ),
    ]

    sut.selectionSet = concernSets.union(diseasesSet).union(allergySets)

    //when
    await sut.signUp(context: modelContext)
    try? await Task.sleep(for: .seconds(1))

    //then
    let user = try await userStore.currentUser()
    XCTAssertNotNil(user)
    let gender = user.gender
    XCTAssertEqual(gender, "남성")
    let userStatus = await userStore.fetchStatuses()
    XCTAssertNotNil(userStatus)
    let result = userStatus.contains(where: { $0.statusType == "임신 중" || $0.statusType == "수유 중" })
    XCTAssertFalse(result,"해당 옵션들이 존재하지 않습니다")
  }

}
