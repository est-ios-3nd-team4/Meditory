import SwiftData
import Foundation

/// 사용자의 신체 프로필(키, 체중) 정보를 관리하는 SwiftData 모델 클래스임.
///
/// 이 모델은 특정 시점의 사용자 키와 체중을 기록하며, `User` 모델과 역관계를 통해 연결됨.
@Model
final class UserProfile: Sendable {
  /// 프로필 기록의 고유 식별자임.
  @Attribute(.unique) var id: UUID
  
  /// 사용자의 키 (cm 단위). 정보가 없을 경우 nil이 될 수 있음.
  var height: Double?
  
  /// 사용자의 체중 (kg 단위). 정보가 없을 경우 nil이 될 수 있음.
  var weight: Double?
  
  /// 이 프로필 정보가 기록된 시점임.
  var createdAt: Date
  
  /// 이 프로필 정보와 연관된 `User` 객체임.
  @Relationship(inverse: \User.userProfiles) var user: User?
  
  /// 새로운 `UserProfile` 인스턴스를 생성하고 초기화함.
  /// - Parameters:
  ///   - id: 고유 UUID. 기본값으로 새로운 UUID가 생성됨.
  ///   - height: 사용자의 키 (cm).
  ///   - weight: 사용자의 체중 (kg).
  ///   - createdAt: 기록 시점. 기본값으로 현재 시간이 설정됨.
  ///   - user: 연관된 `User` 객체.
  init(id: UUID = UUID(), height: Double? = nil, weight: Double? = nil, createdAt: Date = Date(), user: User? = nil) {
    self.id = id
    self.height = height
    self.weight = weight
    self.createdAt = createdAt
    self.user = user
  }
}
