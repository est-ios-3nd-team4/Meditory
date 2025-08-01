import SwiftData
import Foundation

@Model
final class UserStatus {
    @Attribute(.unique) var id: UUID
    var statusType: String // 상태
    var startDate: Date // 시작 날짜
    var endDate: Date? // 종료 날짜(선택적)

    @Relationship(inverse: \User.userStatuses) var user: User?

    init(id: UUID = UUID(), statusType: String, startDate: Date, endDate: Date? = nil, user: User? = nil) {
        self.id = id
        self.statusType = statusType
        self.startDate = startDate
        self.endDate = endDate
        self.user = user
    }
}
