import SwiftData
import Foundation

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var height: Double? // cm 단위, 선택적
    var weight: Double? // kg 단위, 선택적
    var createdAt: Date // 기록 시점

    @Relationship(inverse: \User.userProfiles) var user: User?

    init(id: UUID = UUID(), height: Double? = nil, weight: Double? = nil, createdAt: Date = Date(), user: User? = nil) {
        self.id = id
        self.height = height
        self.weight = weight
        self.createdAt = createdAt
        self.user = user
    }
}
