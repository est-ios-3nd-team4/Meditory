import SwiftData
import Foundation

@Model
final class UserAllergy {
    @Attribute(.unique) var id: UUID
    var allergyType: String // 알러지 종류

    @Relationship(inverse: \User.userAllergies) var user: User? // userId 관계

    init(id: UUID = UUID(), allergyType: String, user: User? = nil) {
        self.id = id
        self.allergyType = allergyType
        self.user = user
    }
}
