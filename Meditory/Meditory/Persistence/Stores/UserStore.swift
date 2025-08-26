import Foundation
import SwiftData


// add 는 따로 객체를 미리 만들고 DB에 추가하는 함수
// create 는 이 함수에서 객체까지 만들면서 한방에 DB에 추가하는 함수

// @ModelActor 방식으로 변경


@ModelActor
actor UserStore {
  static let shared = UserStore(modelContainer: DataController.shared.container)
  
  //  var currentUser: User?
  private var currentUserID: PersistentIdentifier?
  private enum storeError: Error {
    case noCurrentUser
  }
  
  /// 현재 유저 정보 가져오기
  func currentUser() throws -> User {
    guard let id = currentUserID,
          let user = modelContext.model(for: id) as? User else {
      throw storeError.noCurrentUser
    }
    return user
  }
  
  
  // MARK: - User
  /// 유저 하나밖에 없을테지만 추후 확장성을 위해 우선 배열로 만듬
  /// 모든 User 객체를 DB에서 불러오는 함수
  func fetchUsers() -> [User] {
    let descriptor = FetchDescriptor<User>()
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 외부에서 생성한 User 객체를 DB에 저장하는 함수
  func addUser(_ user: User) async -> PersistentIdentifier {
    modelContext.insert(user)
    try? modelContext.save()
    return user.persistentModelID // ID를 반환하도록 추가
  }
  
  /// User 객체를 DB에서 삭제하는 함수
  func deleteUser(id: PersistentIdentifier) async { // User 대신 ID를 받도록 변경
    guard let user = modelContext.model(for: id) as? User else { return }
    modelContext.delete(user)
    try? modelContext.save()
  }
  
  /// DB에서 첫 번째 User 객체를 currentUser에 로드하는 함수
  func loadUser() {
    let descriptor = FetchDescriptor<User>()
    if let first = try? modelContext.fetch(descriptor).first {
      self.currentUserID = first.persistentModelID
    } else {
      self.currentUserID = nil
    }
  }
  
  /// 모든 유저 객체를 삭제하는 함수
  func deleteAllUsers() {
    let users = fetchUsers()
    for user in users {
      modelContext.delete(user)
    }
    try? modelContext.save()
  }
  
  // MARK: - UserProfile
  /// 특정 User와 연결된 UserProfile 목록을 불러오는 함수
  func fetchProfiles() -> [UserProfile] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserProfile>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 외부에서 생성된 UserProfile을 currentUser에 연결하고 DB에 저장하는 함수
  func addUserProfile(_ profile: UserProfile) {
    guard let user = try? currentUser() else { return }
    profile.user = user
    modelContext.insert(profile)
    try? modelContext.save()
  }
  
  /// height와 weight 정보를 사용해 UserProfile을 생성하고 currentUser에 저장하는 함수
  func createUserProfile(height: Double, weight: Double) {
    guard let user = try? currentUser() else { return }
    let profile = UserProfile(height: height, weight: weight, createdAt: .now, user: user)
    modelContext.insert(profile)
    try? modelContext.save()
  }
  
  /// 모든 프로필 객체를 삭제하는 함수
  func deleteAllProfiles() {
    let profiles = fetchProfiles()
    for profile in profiles {
      modelContext.delete(profile)
    }
    try? modelContext.save()
  }
  
  // MARK: - UserStatus
  /// 모든 UserStatus 객체를 DB에서 불러오는 함수
  func fetchStatuses() -> [UserStatus] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserStatus>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: []
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 외부에서 생성된 UserStatus를 currentUser에 연결하고 DB에 저장하는 함수
  func addUserStatus(_ status: UserStatus) {
    guard let user = try? currentUser() else { return }
    status.user = user
    modelContext.insert(status)
    try? modelContext.save()
  }
  
  /// statusType과 startDate를 이용해 UserStatus를 생성하고 currentUser에 저장하는 함수
  func createUserStatus(statusType: String, startDate: Date) {
    guard let user = try? currentUser() else { return }
    let status = UserStatus(statusType: statusType, startDate: startDate, user: user)
    modelContext.insert(status)
    try? modelContext.save()
  }
  
  // MARK: - UserExtraInfo
  /// 모든 UserExtraInfo 객체를 DB에서 불러오는 함수
  func fetchExtraInfos() -> [UserExtraInfo] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserExtraInfo>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: []
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 외부에서 생성된 UserExtraInfo를 currentUser에 연결하고 DB에 저장하는 함수
  func addUserExtraInfo(_ info: UserExtraInfo) {
    guard let user = try? currentUser() else { return }
    info.user = user
    modelContext.insert(info)
    try? modelContext.save()
  }
  
  //TODO: 이 방식을 지울거면 지우고 남길거면 남기고 확실히 해야함. 현재는 주석처리안하면 실행 안됨.
  /// ExtraInfo 변경을 대비해서 ExtraInfo의 모든 데이터 삭제, 새로insert 하는 함수
//  func resetExtraInfos() {
//    // 1. 기존 ExtraInfo 삭제
//    let fetch = FetchDescriptor<ExtraInfo>()
//    if let all = try? modelContext.fetch(fetch) {
//      for info in all {
//        modelContext.delete(info)
//      }
//    }
//    // 2. 새로운 객체를 생성해서 insert
//    for info in allInitialExtraInfos {
//      let newInfo = ExtraInfo(key: info.key, value: info.value, type: info.type)
//      modelContext.insert(newInfo)
//    }
//    try? modelContext.save()
//  }
  
  
  
  
  // MARK: - 테스트용 메서드
#if DEBUG
  /// 테스트용: 모든 ExtraInfo 가져오기
  func fetchAllExtraInfosForTest() -> [ExtraInfo] {
    let descriptor = FetchDescriptor<ExtraInfo>()
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 테스트용: 더미 ExtraInfo 추가
  func addDummyExtraInfoForTest(key: String, value: String, type: ExtraInfoType) {
    let dummy = ExtraInfo(key: key, value: value, type: type)
    modelContext.insert(dummy)
    try? modelContext.save()
  }
#endif
  
  
  
}
