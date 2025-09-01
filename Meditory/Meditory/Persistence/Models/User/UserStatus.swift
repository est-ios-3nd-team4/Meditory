import SwiftData
import Foundation

/// 사용자의 특정 상태(예: 임신, 질병 등) 및 기간을 관리하는 SwiftData 모델 클래스임.
///
/// 이 모델은 상태의 종류, 시작일, 종료일을 기록하며, `User` 모델과 역관계를 통해 연결됨.
@Model
final class UserStatus: Sendable {
  /// 상태 기록의 고유 식별자임.
  @Attribute(.unique) var id: UUID
  
  /// 사용자의 상태를 나타내는 문자열 (예: "임신중", "수유중").
  var statusType: String
  
  /// 상태가 시작된 날짜.
  var startDate: Date?
  
  /// 상태가 종료된 날짜. 진행 중인 상태의 경우 nil이 될 수 있음.
  var endDate: Date?
  
  /// 이 상태 정보와 연관된 `User` 객체임.
  @Relationship(inverse: \User.userStatuses) var user: User?
  
  /// 새로운 `UserStatus` 인스턴스를 생성하고 초기화함.
  /// - Parameters:
  ///   - id: 고유 UUID. 기본값으로 새로운 UUID가 생성됨.
  ///   - statusType: 사용자의 상태.
  ///   - startDate: 상태 시작 날짜.
  ///   - endDate: 상태 종료 날짜.
  ///   - user: 연관된 `User` 객체.
  init(id: UUID = UUID(), statusType: String, startDate: Date? = nil, endDate: Date? = nil, user: User? = nil) {
    self.id = id
    self.statusType = statusType
    self.startDate = startDate
    self.endDate = endDate
    self.user = user
  }
}
