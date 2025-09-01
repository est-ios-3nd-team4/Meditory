import Foundation
import SwiftData

/// `User` 및 관련 하위 모델들의 SwiftData 작업을 처리하는 ModelActor임.
///
/// 이 액터는 앱의 데이터베이스 컨텍스트에서 사용자 관련 데이터의 생성, 조회, 수정, 삭제 작업을 스레드에 안전하게 관리함.
@ModelActor
actor UserStore {
  /// 앱 전역에서 접근 가능한 공유 싱글턴 인스턴스임.
  static let shared = UserStore(modelContainer: DataController.shared.container)
  
  /// 현재 활성화된 사용자의 `PersistentIdentifier`임.
  private var currentUserID: PersistentIdentifier?
  
  /// `UserStore` 내에서 발생하는 특정 오류를 정의한 열거형임.
  private enum storeError: Error {
    /// 현재 사용자를 찾을 수 없을 때 발생하는 오류임.
    case noCurrentUser
  }
  
  /// 현재 활성화된 `User` 객체를 반환함.
  /// - Throws: `storeError.noCurrentUser` - `currentUserID`가 설정되지 않았거나 유효하지 않을 경우 발생함.
  /// - Returns: 현재 `User` 객체.
  func currentUser() throws -> User {
    guard let id = currentUserID,
          let user = modelContext.model(for: id) as? User else {
      throw storeError.noCurrentUser
    }
    return user
  }
  
  // MARK: - User
  
  /// 데이터베이스에 저장된 모든 `User` 객체를 조회함.
  ///
  /// 일반적으로 이 앱에서는 유저가 한 명이지만, 향후 확장을 고려하여 배열로 반환함.
  /// - Returns: `User` 객체의 배열.
  func fetchUsers() -> [User] {
    let descriptor = FetchDescriptor<User>()
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 새로운 `User` 객체를 데이터베이스에 추가함.
  /// - Parameter user: 데이터베이스에 추가할 `User` 객체.
  /// - Returns: 새로 추가된 `User` 객체의 `PersistentIdentifier`.
  func addUser(_ user: User) async -> PersistentIdentifier {
    modelContext.insert(user)
    try? modelContext.save()
    return user.persistentModelID
  }
  
  /// 주어진 ID를 사용하여 특정 `User` 객체를 데이터베이스에서 삭제함.
  /// - Parameter id: 삭제할 `User`의 `PersistentIdentifier`.
  func deleteUser(id: PersistentIdentifier) async {
    guard let user = modelContext.model(for: id) as? User else { return }
    modelContext.delete(user)
    try? modelContext.save()
  }
  
  /// 데이터베이스에서 첫 번째 `User`를 찾아 `currentUserID`로 설정함.
  ///
  /// 앱 시작 시 호출하여 현재 사용자를 로드하는 데 사용됨.
  func loadUser() {
    let descriptor = FetchDescriptor<User>()
    if let first = try? modelContext.fetch(descriptor).first {
      self.currentUserID = first.persistentModelID
    } else {
      self.currentUserID = nil
    }
  }
  
  /// 데이터베이스에 저장된 모든 `User` 객체를 삭제함.
  func deleteAllUsers() {
    let users = fetchUsers()
    for user in users {
      modelContext.delete(user)
    }
    try? modelContext.save()
  }
  
  // MARK: - UserProfile
  
  /// 현재 사용자와 연결된 모든 `UserProfile` 목록을 생성일 내림차순으로 정렬하여 조회함.
  /// - Returns: `UserProfile` 객체의 배열.
  func fetchProfiles() -> [UserProfile] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserProfile>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 새로운 `UserProfile` 객체를 현재 사용자에게 연결하고 데이터베이스에 저장함.
  /// - Parameter profile: 추가할 `UserProfile` 객체.
  func addUserProfile(_ profile: UserProfile) {
    guard let user = try? currentUser() else { return }
    profile.user = user
    modelContext.insert(profile)
    try? modelContext.save()
  }
  
  /// 신장과 체중 정보로 `UserProfile`을 생성하여 현재 사용자에게 연결하고 저장함.
  /// - Parameters:
  ///   - height: 사용자의 신장(cm).
  ///   - weight: 사용자의 체중(kg).
  func createUserProfile(height: Double, weight: Double) {
    guard let user = try? currentUser() else { return }
    let profile = UserProfile(height: height, weight: weight, createdAt: .now, user: user)
    modelContext.insert(profile)
    try? modelContext.save()
  }
  
  /// 현재 사용자와 연결된 모든 `UserProfile` 객체를 삭제함.
  func deleteAllProfiles() {
    let profiles = fetchProfiles()
    for profile in profiles {
      modelContext.delete(profile)
    }
    try? modelContext.save()
  }
  
  // MARK: - UserStatus
  
  /// 현재 사용자와 연결된 모든 `UserStatus` 객체를 조회함.
  /// - Returns: `UserStatus` 객체의 배열.
  func fetchStatuses() -> [UserStatus] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserStatus>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: []
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 새로운 `UserStatus` 객체를 현재 사용자에게 연결하고 데이터베이스에 저장함.
  /// - Parameter status: 추가할 `UserStatus` 객체.
  func addUserStatus(_ status: UserStatus) {
    guard let user = try? currentUser() else { return }
    status.user = user
    modelContext.insert(status)
    try? modelContext.save()
  }
  
  /// 상태 타입과 시작 날짜로 `UserStatus`를 생성하여 현재 사용자에게 연결하고 저장함.
  /// - Parameters:
  ///   - statusType: 상태를 나타내는 문자열 (예: "임신중").
  ///   - startDate: 상태 시작 날짜.
  func createUserStatus(statusType: String, startDate: Date) {
    guard let user = try? currentUser() else { return }
    let status = UserStatus(statusType: statusType, startDate: startDate, user: user)
    modelContext.insert(status)
    try? modelContext.save()
  }
  
  // MARK: - UserExtraInfo
  
  /// 현재 사용자와 연결된 모든 `UserExtraInfo` 객체를 조회함.
  /// - Returns: `UserExtraInfo` 객체의 배열.
  func fetchExtraInfos() -> [UserExtraInfo] {
    guard let user = try? currentUser() else { return [] }
    let userIDOpt: PersistentIdentifier? = user.persistentModelID
    let descriptor = FetchDescriptor<UserExtraInfo>(
      predicate: #Predicate { $0.user?.persistentModelID == userIDOpt },
      sortBy: []
    )
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 새로운 `UserExtraInfo` 객체를 현재 사용자에게 연결하고 데이터베이스에 저장함.
  /// - Parameter info: 추가할 `UserExtraInfo` 객체.
  func addUserExtraInfo(_ info: UserExtraInfo) {
    guard let user = try? currentUser() else { return }
    info.user = user
    modelContext.insert(info)
    try? modelContext.save()
  }
  
  // MARK: - Update (정보 수정용 함수)
  
  /// 현재 사용자의 모든 정보를 한 번에 업데이트하고 데이터베이스에 저장함.
  /// - Parameters:
  ///   - name: 실명.
  ///   - displayName: 표시 이름.
  ///   - birthDate: 생년월일.
  ///   - gender: 성별.
  ///   - height: 신장.
  ///   - weight: 체중.
  ///   - allergies: 알러지 정보 배열.
  ///   - diseases: 질병 정보 배열.
  ///   - concerns: 건강 고민 정보 배열.
  ///   - statuses: 건강 상태 문자열 배열.
  func updateAllUserInfo(
    name: String,
    displayName: String,
    birthDate: Date,
    gender: String,
    height: Double,
    weight: Double,
    allergies: [ExtraInfo],
    diseases: [ExtraInfo],
    concerns: [ExtraInfo],
    statuses: [String]
  ) {
    guard let user = try? currentUser() else {
      print("Update failed: Could not find current user.")
      return
    }
    
    // 1. User 기본 정보 업데이트
    user.name = name
    user.displayName = displayName
    user.birthDate = birthDate
    user.gender = gender
    
    // 2. 새로운 UserProfile 기록 추가 (기존 기록은 보존)
    let newProfile = UserProfile(height: height, weight: weight, user: user)
    modelContext.insert(newProfile)
    
    // 3. UserExtraInfo 업데이트 (명시적 삭제 및 추가)
    if let existingInfo = user.userExtraInfos.first {
      // 기존 데이터를 임시 변수에 복사한 뒤, 관계 배열을 비움.
      let oldAllergies = existingInfo.allergy
      let oldDiseases = existingInfo.disease
      let oldConcerns = existingInfo.concern
      existingInfo.allergy = []
      existingInfo.disease = []
      existingInfo.concern = []
      
      // 복사본을 순회하며 안전하게 삭제함.
      oldAllergies.forEach { modelContext.delete($0) }
      oldDiseases.forEach { modelContext.delete($0) }
      oldConcerns.forEach { modelContext.delete($0) }
      
      // 새로운 ExtraInfo 객체들을 관계에 할당함.
      existingInfo.allergy = allergies
      existingInfo.disease = diseases
      existingInfo.concern = concerns
    } else {
      // UserExtraInfo가 아예 없었다면 새로 만듬.
      let newExtraInfo = UserExtraInfo(disease: diseases, allergy: allergies, concern: concerns, user: user)
      modelContext.insert(newExtraInfo)
    }
    
    // 4. UserStatus 업데이트 (명시적 삭제 및 추가)
    // 기존 상태들을 임시 변수에 복사한 뒤, 관계 배열을 비움.
    let oldStatuses = user.userStatuses
    user.userStatuses = []
    
    // 복사본을 순회하며 안전하게 삭제함.
    oldStatuses.forEach { modelContext.delete($0) }
    
    // 새로운 상태들을 생성하고 관계에 추가함.
    user.userStatuses = statuses.map { statusTitle in
      let newStatus = UserStatus(statusType: statusTitle, user: user)
      return newStatus
    }
    
    // 5. 모든 변경사항을 마지막에 한 번만 저장함.
    do {
      try modelContext.save()
      print("✅ All user info updated and saved successfully.")
    } catch {
      print("🚨 CRITICAL: Failed to save all user info. Error: \(error)")
    }
  }
  
  // MARK: - 테스트용 메서드
#if DEBUG
  /// 테스트용: 모든 `ExtraInfo` 객체를 조회함.
  func fetchAllExtraInfosForTest() -> [ExtraInfo] {
    let descriptor = FetchDescriptor<ExtraInfo>()
    return (try? modelContext.fetch(descriptor)) ?? []
  }
  
  /// 테스트용: 더미 `ExtraInfo` 객체를 추가함.
  func addDummyExtraInfoForTest(key: String, value: String, type: ExtraInfoType) {
    let dummy = ExtraInfo(key: key, value: value, type: type)
    modelContext.insert(dummy)
    try? modelContext.save()
  }
#endif
  
}
