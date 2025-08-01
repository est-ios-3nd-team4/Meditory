import SwiftData
import Foundation

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthDate: Date
    var gender: String
    var displayName: String
    
    @Relationship var userProfiles: [UserProfile] = []
    @Relationship var userStatuses: [UserStatus] = []
    @Relationship var userAllergies: [UserAllergy] = []
    @Relationship var userExtraInfos: [UserExtraInfo] = []


    var currentProfile: UserProfile? {
        userProfiles.sorted { $0.createdAt > $1.createdAt }.first
    }
    
    init(id: UUID = UUID(), name: String, birthDate: Date, gender: String, displayName: String) {
        self.id = id
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.displayName = displayName
    }
}
