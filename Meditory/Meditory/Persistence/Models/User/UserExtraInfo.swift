import SwiftData
import Foundation

/// 사용자의 추가적인 건강 정보를 관리하는 SwiftData 모델 클래스임.
///
/// 이 모델은 사용자의 질병, 알레르기, 건강 관심사 정보를 각각의 `ExtraInfo` 배열로 저장하고,
/// `User` 모델과 역관계를 통해 연결됨.
@Model
final class UserExtraInfo: Sendable {
  /// 추가 정보 객체의 고유 식별자임.
  @Attribute(.unique) var id: UUID
  
  /// 사용자가 가진 질병 목록. 이 객체가 삭제되면 연관된 질병 정보도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var disease: [ExtraInfo]
  
  /// 사용자가 가진 알레르기 목록. 이 객체가 삭제되면 연관된 알레르기 정보도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var allergy: [ExtraInfo]
  
  /// 사용자의 건강 관련 관심사 목록. 이 객체가 삭제되면 연관된 관심사 정보도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var concern: [ExtraInfo]
  
  /// 이 추가 정보와 연관된 `User` 객체임.
  @Relationship(inverse: \User.userExtraInfos) var user: User?
  
  /// 새로운 `UserExtraInfo` 인스턴스를 생성하고 초기화함.
  /// - Parameters:
  ///   - id: 고유 UUID. 기본값으로 새로운 UUID가 생성됨.
  ///   - disease: 질병 정보 배열.
  ///   - allergy: 알레르기 정보 배열.
  ///   - concern: 건강 관심사 정보 배열.
  ///   - user: 연관된 `User` 객체.
  init(id: UUID = UUID(), disease: [ExtraInfo] = [], allergy: [ExtraInfo] = [], concern: [ExtraInfo] = [], user: User? = nil) {
    self.id = id
    self.disease = disease
    self.allergy = allergy
    self.concern = concern
    self.user = user
  }
}
