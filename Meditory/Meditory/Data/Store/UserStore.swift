import Foundation
import SwiftData


// add 는 따로 객체를 미리 만들고 DB에 추가하는 함수
// create 는 이 함수에서 객체까지 만들면서 한방에 DB에 추가하는 함수


@Observable
final class UserStore {

    var currentUser: User?

    // MARK: - User
    /// 유저 하나밖에 없을테지만 추후 확장성을 위해 우선 배열로 만듬
    /// 모든 User 객체를 DB에서 불러오는 함수
    @MainActor
    func fetchUsers(context: ModelContext) -> [User] {
        let descriptor = FetchDescriptor<User>()
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 외부에서 생성한 User 객체를 DB에 저장하는 함수
    @MainActor
    func addUser(_ user: User, context: ModelContext) {
        context.insert(user)
        try? context.save()
    }

    /// User 객체를 DB에서 삭제하는 함수
    @MainActor
    func deleteUser(_ user: User, context: ModelContext) {
        context.delete(user)
        try? context.save()
    }

    /// DB에서 첫 번째 User 객체를 currentUser에 로드하는 함수
    @MainActor
    func loadUser(context: ModelContext) {
        let descriptor = FetchDescriptor<User>()
        self.currentUser = try? context.fetch(descriptor).first
    }

    /// 모든 유저 객체를 삭제하는 함수
    @MainActor
    func deleteAllUsers(context: ModelContext) {
        let users = fetchUsers(context: context)
        for user in users {
            context.delete(user)
        }
        try? context.save()
    }

    // MARK: - UserProfile
    /// 특정 User와 연결된 UserProfile 목록을 불러오는 함수
    @MainActor
    func fetchProfiles(context: ModelContext) -> [UserProfile] {
        let descriptor = FetchDescriptor<UserProfile>(
//          predicate: #Predicate { $0.user == user }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 외부에서 생성된 UserProfile을 currentUser에 연결하고 DB에 저장하는 함수
    @MainActor
    func addUserProfile(_ profile: UserProfile, context: ModelContext) {
        guard let user = currentUser else { return }
        profile.user = user
        user.userProfiles.append(profile)
        context.insert(profile)
        try? context.save()
    }

    /// height와 weight 정보를 사용해 UserProfile을 생성하고 currentUser에 저장하는 함수
    @MainActor
    func createUserProfile(height: Double, weight: Double, context: ModelContext) {
        guard let user = currentUser else { return }
        let profile = UserProfile(height: height, weight: weight, createdAt: .now, user: user)
        user.userProfiles.append(profile)
        context.insert(profile)
        try? context.save()
    }

    /// 모든 프로필 객체를 삭제하는 함수
    @MainActor
    func deleteAllProfiles(context: ModelContext) {
        let profiles = fetchProfiles(context: context)
        for profile in profiles {
            context.delete(profile)
        }
        try? context.save()
    }

    // MARK: - UserStatus
    /// 모든 UserStatus 객체를 DB에서 불러오는 함수
    @MainActor
    func fetchStatuses(context: ModelContext) -> [UserStatus] {
        let descriptor = FetchDescriptor<UserStatus>()
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 외부에서 생성된 UserStatus를 currentUser에 연결하고 DB에 저장하는 함수
    @MainActor
    func addUserStatus(_ status: UserStatus, context: ModelContext) {
        guard let user = currentUser else { return }
        status.user = user
        user.userStatuses.append(status)
        context.insert(status)
        try? context.save()
    }

    /// statusType과 startDate를 이용해 UserStatus를 생성하고 currentUser에 저장하는 함수
    @MainActor
    func createUserStatus(statusType: String, startDate: Date, context: ModelContext) {
        guard let user = currentUser else { return }
        let status = UserStatus(statusType: statusType, startDate: startDate, user: user)
        user.userStatuses.append(status)
        context.insert(status)
        try? context.save()
    }

    // MARK: - UserExtraInfo
    /// 모든 UserExtraInfo 객체를 DB에서 불러오는 함수
    @MainActor
    func fetchExtraInfos(context: ModelContext) -> [UserExtraInfo] {
        let descriptor = FetchDescriptor<UserExtraInfo>()
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 외부에서 생성된 UserExtraInfo를 currentUser에 연결하고 DB에 저장하는 함수
    @MainActor
    func addUserExtraInfo(_ info: UserExtraInfo, context: ModelContext) {
        guard let user = currentUser else { return }
        info.user = user
        user.userExtraInfos.append(info)
        context.insert(info)
        try? context.save()
    }

    /// key와 value를 사용해 UserExtraInfo를 생성하고 currentUser에 저장하는 함수
    @MainActor
    func createUserExtraInfo(key: String, value: String, context: ModelContext) {
        guard let user = currentUser else { return }
        let info = UserExtraInfo(infoKey: key, infoValue: value, user: user)
        user.userExtraInfos.append(info)
        context.insert(info)
        try? context.save()
    }

    // MARK: - UserAllergy
    /// 모든 UserAllergy 객체를 DB에서 불러오는 함수
    @MainActor
    func fetchAllergies(context: ModelContext) -> [UserAllergy] {
        let descriptor = FetchDescriptor<UserAllergy>()
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 외부에서 생성된 UserAllergy를 currentUser에 연결하고 DB에 저장하는 함수
    @MainActor
    func addUserAllergy(_ allergy: UserAllergy, context: ModelContext) {
        guard let user = currentUser else { return }
        allergy.user = user
        user.userAllergies.append(allergy)
        context.insert(allergy)
        try? context.save()
    }

    /// allergyType을 사용해 UserAllergy를 생성하고 currentUser에 저장하는 함수
    @MainActor
    func createUserAllergy(allergyType: String, context: ModelContext) {
        guard let user = currentUser else { return }
        let allergy = UserAllergy(allergyType: allergyType, user: user)
        user.userAllergies.append(allergy)
        context.insert(allergy)
        try? context.save()
    }
}
