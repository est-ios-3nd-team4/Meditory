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
  var userStore: UserStore!
  var sut: OnboardingViewModel!

  // 테스트 준비 과정에 비동기 작업이 있으므로, setUp을 async로 변경합니다.
  override func setUp() async throws {
    let schema = Schema([User.self, UserExtraInfo.self, UserProfile.self, UserStatus.self, ExtraInfo.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    userStore = UserStore(modelContainer: container)
    // ViewModel은 @MainActor로 보호되므로, await으로 초기화합니다.
    sut = await OnboardingViewModel(userStore: userStore)
  }

  override func tearDownWithError() throws {
    container = nil
    userStore = nil
    sut = nil
  }

  /// 각 필드의 유효성 검사
  func test_eachField_validation() async throws {
    // given: 각 필드의 내용을 업데이트합니다.
    await sut.updateContent(.height, context: "170")
    await sut.updateContent(.weight, context: "179")
    await sut.updateContent(.name, context: "james")
    await sut.updateContent(.birthDate, context: "1999")

    // when: 각 필드의 유효성을 검사합니다.
    await sut.validate(.height)
    await sut.validate(.weight)
    await sut.validate(.name)
    await sut.validate(.birthDate)

    // then: MainActor에서 안전하게 결과를 검증합니다.
    await MainActor.run {
      let heightResult = try? XCTUnwrap(sut.fieldStates[.height]?.isValid)
      let weightResult = try? XCTUnwrap(sut.fieldStates[.weight]?.isValid)
      let nameResult = try? XCTUnwrap(sut.fieldStates[.name]?.isValid)
      let bodResult = try? XCTUnwrap(sut.fieldStates[.birthDate]?.isValid)

      XCTAssertTrue(heightResult ?? false, "키가 유효하지 않습니다")
      XCTAssertTrue(weightResult ?? false, "체중이 유효하지 않습니다")
      XCTAssertTrue(nameResult ?? false, "이름이 유효하지 않습니다")
      XCTAssertTrue(bodResult ?? false, "생년월일이 유효하지 않습니다")
    }
  }
  
  /// 기본 가입정보들이 모두 유효할 경우 다음 버튼이 활성화되어야 한다
  func test_nextButton_shouldActivate_whenInputsAreValid() async throws {
    // given
    await sut.updateContent(.name, context: "James")
    await sut.updateContent(.weight, context: "155.53")
    await sut.updateContent(.height, context: "150")
    await sut.updateContent(.birthDate, context: "1999")

    // when
    await sut.validateAllField()

    // then
    // isNextButtonOn은 @MainActor로 보호되므로, MainActor.run 블록 안에서 접근합니다.
    await MainActor.run {
      XCTAssertTrue(sut.isNextButtonOn,"다음 버튼이 활성화되어있지 않습니다.")
    }
  }

  /// 유저가 남성일 경우 회원가입 완료 후 유저상태에서 여성관련 옵션들이 존재하면 안된다
  func test_userIsMan_noWomanOptionFound() async throws {
    // given
    // sut의 프로퍼티는 MainActor에서 수정하는 것이 안전합니다.
    await MainActor.run {
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
    }

    // when
    // signUp 함수가 오류를 던질 수 있으므로 try await으로 호출합니다.
    try await sut.signUp()

    // then
    // signUp 함수가 이제 모든 작업이 끝날 때까지 기다리므로, 안전하게 currentUser를 조회할 수 있습니다.
    let user = try await userStore.currentUser()
    XCTAssertNotNil(user, "회원가입 후 User 객체가 생성되어야 합니다.")
    
    XCTAssertEqual(user.gender, "남성")
    
    let userStatus = await userStore.fetchStatuses()
    let result = userStatus.contains(where: { $0.statusType == "임신 중" || $0.statusType == "수유 중" })
    XCTAssertFalse(result,"남성 유저의 상태 정보에 여성 관련 옵션(임신, 수유)이 포함되면 안 됩니다.")
  }
}
