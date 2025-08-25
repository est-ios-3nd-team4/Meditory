import XCTest
import SwiftData
@testable import Meditory

final class UserTest: XCTestCase {
  
  var container: ModelContainer!
  var store: UserStore!
  
  override func setUpWithError() throws {
    // 모든 모델을 포함하는 컨테이너 생성
    let schema = Schema([
      User.self,
      UserProfile.self,
      UserStatus.self,
      UserExtraInfo.self,
      ExtraInfo.self
    ])
    
    container = try ModelContainer(
      for: schema,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)  // 테스트용 메모리 DB
    )
    
    // UserStore 생성
    store = UserStore(modelContainer: container)
  }
  
  override func tearDownWithError() throws {
    container = nil
    store = nil
  }
  
  /// User 생성 테스트
  func testCreateUserProfile() async throws {
    // Given: 유저를 먼저 생성하고 저장
    let user = User(name: "스티브잡스", birthDate: .now, gender: "남", displayName: "잡스형")
    _ = await store.addUser(user)
    await store.loadUser()  // currentUser 설정
    
    // When: 프로필을 생성
    await store.createUserProfile(height: 175.0, weight: 65.0)
    
    // Then: 프로필이 잘 추가됐는지 확인
    let profiles = await store.fetchProfiles()
    XCTAssertEqual(profiles.count, 1)
    let profile = profiles.first!
    XCTAssertEqual(profile.height, 175.0)
    XCTAssertEqual(profile.weight, 65.0)
    XCTAssertNotNil(profile.user)
  }
  
  /// UserStatus 테스트
  func testCreateUserStatus() async throws {
    // Given: 유저를 먼저 생성하고 저장
    let user = User(name: "김여자", birthDate: .now, gender: "여", displayName: "여자킴")
    _ = await store.addUser(user)
    await store.loadUser()
    
    // When: 현재 진행 중인 상태 생성
    await store.createUserStatus(statusType: "모유수유중", startDate: .now)
    
    // When: 과거 종료된 상태 생성
    let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: .now)!
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    
    let endedStatus = UserStatus(statusType: "임신중", startDate: thirtyDaysAgo, user: nil)
    endedStatus.endDate = yesterday
    await store.addUserStatus(endedStatus)
    
    // Then: 상태가 두 개 생성되었는지 확인
    let statuses = await store.fetchStatuses()
    XCTAssertEqual(statuses.count, 2)
    
    // 현재 진행 중인 상태 확인
    let currentStatus = statuses.first { $0.statusType == "모유수유중" }
    XCTAssertNotNil(currentStatus)
    XCTAssertNil(currentStatus?.endDate)
    
    // 과거 상태 확인
    let pastStatus = statuses.first { $0.statusType == "임신중" }
    XCTAssertNotNil(pastStatus)
    XCTAssertNotNil(pastStatus?.endDate)
    XCTAssertEqual(pastStatus?.endDate, yesterday)
  }
  
  /// UserExtraInfo 테스트
  /*
  // TODO: 🚀 빌드 에러나는 테스트 코드 수정 후 재활성화
  @MainActor
  func testCreateUserExtraInfo() async throws {
    // Given
    let user = User(name: "손오공", birthDate: .now, gender: "남", displayName: "원숭이")
    await store.addUser(user)
    await store.loadUser()
    
    // ExtraInfo 먼저 초기화
    await store.resetExtraInfos()
    
    // 초기화 후 전역 데이터에서 안전하게 가져오기
    let availableDiseases = await store.fetchAllExtraInfosForTest().filter { $0.type == .disease }
    let availableAllergies = await store.fetchAllExtraInfosForTest().filter { $0.type == .allergy }
    let availableConcerns = await store.fetchAllExtraInfosForTest().filter { $0.type == .concern }
    
    // 실제 존재하는 데이터에서 선택
    let selectedDiseases = Array(availableDiseases.prefix(2))  // 처음 2개
    let selectedAllergies = Array(availableAllergies.prefix(3)) // 처음 3개
    let selectedConcerns = Array(availableConcerns.prefix(2))   // 처음 2개
    
    // When
    let extraInfo = UserExtraInfo(
      disease: selectedDiseases,
      allergy: selectedAllergies,
      concern: selectedConcerns,
      user: nil
    )
    await store.addUserExtraInfo(extraInfo)
    
    // Then
    let infos = await store.fetchExtraInfos()
    XCTAssertEqual(infos.count, 1)
    let info = infos.first!
    XCTAssertEqual(info.disease.count, 2)
    XCTAssertEqual(info.allergy.count, 3)
    XCTAssertEqual(info.concern.count, 2)
    XCTAssertNotNil(info.user)
  }
  
  
  /// ExtraInfo 참조데이터 리셋 테스트
  func testResetExtraInfos() async throws {
    // 0. ExtraInfo가 없는 상태에서 reset
    await store.resetExtraInfos()
    
    // 직접 ModelContext에 접근해서 확인 (테스트용)
    let allExtraInfos = await withCheckedContinuation { continuation in
      Task {
        let result = await store.fetchAllExtraInfosForTest()  // 테스트용 메서드 필요
        continuation.resume(returning: result)
      }
    }
    
    XCTAssertEqual(allExtraInfos.count, allInitialExtraInfos.count, "데이터 개수가 정확히 초기 스크립트 개수와 같아야 함")
    
    // 1. 일부러 임의 데이터 추가 후 reset
    await store.addDummyExtraInfoForTest(key: "disease_999", value: "더미", type: .disease)
    
    // 2. 다시 초기화
    await store.resetExtraInfos()
    
    let finalExtraInfos = await store.fetchAllExtraInfosForTest()
    XCTAssertEqual(finalExtraInfos.count, allInitialExtraInfos.count, "초기화 후 개수는 항상 같아야 함")
    XCTAssertFalse(finalExtraInfos.contains(where: { $0.key == "disease_999" }), "초기화 후 더미 데이터는 남아있으면 안 됨")
    
    // 3. 값 검증
    let disease4 = finalExtraInfos.first(where: { $0.key == "disease_4" })
    XCTAssertEqual(disease4?.value, "고지혈증")
    XCTAssertEqual(disease4?.type, .disease)
  }
  */
}
