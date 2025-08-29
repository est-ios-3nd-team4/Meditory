import SwiftData
import Foundation

@Model
final class UserExtraInfo {
  @Attribute(.unique) var id: UUID
  
  @Relationship(deleteRule: .cascade) var disease: [ExtraInfo]
  @Relationship(deleteRule: .cascade) var allergy: [ExtraInfo]
  @Relationship(deleteRule: .cascade) var concern: [ExtraInfo]
  
  @Relationship(inverse: \User.userExtraInfos) var user: User?
  
  init(id: UUID = UUID(), disease: [ExtraInfo] = [], allergy: [ExtraInfo] = [], concern: [ExtraInfo] = [], user: User? = nil) {
    self.id = id
    self.disease = disease
    self.allergy = allergy
    self.concern = concern
    self.user = user
  }
}
