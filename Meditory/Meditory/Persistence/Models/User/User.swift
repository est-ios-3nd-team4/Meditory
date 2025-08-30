import SwiftData
import Foundation

@Model
final class User: Sendable {
  @Attribute(.unique) var id: UUID
  var name: String
  var birthDate: Date
  var gender: String
  var displayName: String
  
  @Relationship(deleteRule: .cascade) var userProfiles: [UserProfile] = []
  @Relationship(deleteRule: .cascade) var userStatuses: [UserStatus] = []
  @Relationship(deleteRule: .cascade) var userExtraInfos: [UserExtraInfo] = []
  @Relationship(deleteRule: .cascade) var userLifeStyle: UserLifeStyle?
  
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
