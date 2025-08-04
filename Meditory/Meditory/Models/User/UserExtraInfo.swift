import SwiftData
import Foundation

@Model
final class UserExtraInfo {
    @Attribute(.unique) var id: UUID
    var infoKey: String // 정보 종류 (예: 복용중약물, 질환 등)
    var infoValue: String // 정보 값 (예: 약물명, 질환명 등)

    @Relationship(inverse: \User.userExtraInfos) var user: User? // userId 관계

    init(id: UUID = UUID(), infoKey: String, infoValue: String, user: User? = nil) {
        self.id = id
        self.infoKey = infoKey
        self.infoValue = infoValue
        self.user = user
    }
}
