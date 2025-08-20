import SwiftData
import Foundation

@Model
final class UserExtraInfo: @unchecked Sendable {
  @Attribute(.unique) var id: UUID
  var disease: [ExtraInfo]
  var allergy: [ExtraInfo]
  var concern: [ExtraInfo]
  
  
  @Relationship(inverse: \User.userExtraInfos) var user: User? // userId 관계
  
  init(id: UUID = UUID(), disease: [ExtraInfo] = [], allergy: [ExtraInfo] = [], concern: [ExtraInfo] = [], user: User? = nil) {
    self.id = id
    self.disease = disease
    self.allergy = allergy
    self.concern = concern
    self.user = user
  }
}
