import SwiftData
import Foundation

@Model
final class Setting: Sendable {
  @Attribute(.unique) var id: UUID
  var isNotificationOn: Bool // 알림 허용 여부
  
  init(id: UUID = UUID(), isNotificationOn: Bool) {
    self.id = id
    self.isNotificationOn = isNotificationOn
  }
}
