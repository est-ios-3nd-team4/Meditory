import SwiftData
import SwiftUI
import XCTest

@testable import Meditory

final class OnboardingUnitTest: XCTestCase {

  var container: ModelContainer!
  var userStore: UserStore!
  var sut: OnboardingViewModel!

  // setUpWithError는 비동기 작업을 포함하므로 async로 변경합니다.
  override func setUp() async throws {
    let schema = Schema([User.self, UserExtraInfo.self, UserProfile.self, UserStatus.self, ExtraInfo.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    userStore = UserStore(modelContainer: container)
    // sut를 초기화할 때 await을 사용하고, 더 이상 불필요한 Task로 감싸지 않습니다.
    sut = await OnboardingViewModel(userStore: userStore)
  }

  override func tearDownWithError() throws {
    container = nil
    userStore = nil
    sut = nil
  }

  ///각필드의 유효성 검사
  func test_eachField_validation() async throws {
    // given: 각 필드의 내용을 업데이트합니다.
    await sut.updateContent(.height, context: "140")
    await sut.updateContent(.weight, context: "179")
    await sut.updateContent(.name, context: "james")
    await sut.updateContent(.birthDate, context: "2025")

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

      XCTAssertTrue(heightResult ?? false, "Height validation should be true")
      XCTAssertTrue(weightResult ?? false, "Weight validation should be true")
      XCTAssertTrue(nameResult ?? false, "Name validation should be true")
      XCTAssertTrue(bodResult ?? false, "Birth date validation should be true")
    }
  }
  
  /// 기본 가입정보들이 모두 유효할 경우 다음 버튼이 활성화되어야 한다
  func test_userEnter_validInputs_enablesNextButton() async throws {
    // given
    await sut.updateContent(.name, context: "James")
    await sut.updateContent(.weight, context: "155.53")
    await sut.updateContent(.height, context: "150")
    await sut.updateContent(.birthDate, context: "1999")

    // when
    await sut.validateAllField()

    // then
    // sut.isNextButtonOn이 @MainActor로 보호되므로 MainActor.run 블록 안에서 접근합니다.
    await MainActor.run {
      XCTAssertTrue(self.sut.isNextButtonOn, "Next button should be enabled when all fields are valid")
    }
  }

  /// 유저가 남성일 경우 회원가입 완료 후 유저상태에서 여성관련 옵션들이 존재하면 안된다
  func test_userIsMan_noWomanOptionFound() async throws {
    // given
    // sut의 프로퍼티는 @MainActor로 보호되므로 MainActor.run 안에서 수정합니다.
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
          toggleImage: .name(base: "nuts_seeds")
        ),
        .init(
          code: "allergy_4",
          title: "해산물",
          type: .allergy,
          toggleImage: .name(base: "seafood")
        ),
      ]
      sut.selectionSet = concernSets.union(diseasesSet).union(allergySets)
    }

    // when
    // signUp 메서드는 더 이상 context를 받지 않고, 오류를 던질 수 있으므로 try await으로 호출합니다.
    try await sut.signUp()

    // then
    let user = try await userStore.currentUser()
    let userStatus = await userStore.fetchStatuses()
    let result = userStatus.contains { $0.statusType == "임신 중" || $0.statusType == "수유 중" }
    
    XCTAssertNotNil(user, "User should be created after sign up")
    XCTAssertFalse(result, "User status should not contain woman-specific options for a male user")
  }
}
