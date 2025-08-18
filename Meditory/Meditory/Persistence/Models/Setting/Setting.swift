import SwiftData
import Foundation

// 굳이 왜 만들지 싶겠지만 추후 확장 고려해서 테이블 생성

@Model
final class Setting {
    @Attribute(.unique) var id: UUID
    var isNotificationOn: Bool // 알림 허용 여부

    init(id: UUID = UUID(), isNotificationOn: Bool) {
        self.id = id
        self.isNotificationOn = isNotificationOn
    }
}
