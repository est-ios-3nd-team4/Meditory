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
}
