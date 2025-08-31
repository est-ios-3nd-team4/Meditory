import SwiftData
import Foundation

/// 사용자 정보를 나타내는 SwiftData 모델 클래스임.
///
/// 이 모델은 사용자의 기본 정보(이름, 생년월일 등)와 함께
/// 신체 프로필, 건강 상태, 생활 습관 등 다양한 하위 데이터와의 관계를 관리함.
@Model
final class User: Sendable {
  /// 사용자의 고유 식별자임.
  @Attribute(.unique) var id: UUID
  
  /// 사용자의 실명임.
  var name: String
  
  /// 사용자의 생년월일임.
  var birthDate: Date
  
  /// 사용자의 성별임.
  var gender: String
  
  /// 앱 내에서 표시될 사용자의 별명임.
  var displayName: String
  
  /// 사용자의 모든 신체 프로필(키, 체중 등) 기록. 사용자가 삭제되면 연관된 프로필도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var userProfiles: [UserProfile] = []
  
  /// 사용자의 특정 상태(예: 임신, 질병 등) 목록. 사용자가 삭제되면 연관된 상태도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var userStatuses: [UserStatus] = []
  
  /// 사용자의 추가 정보(알레르기, 기저질환 등)와의 관계. 사용자가 삭제되면 연관된 추가 정보도 모두 삭제됨.
  @Relationship(deleteRule: .cascade) var userExtraInfos: [UserExtraInfo] = []
  
  /// 사용자의 생활 습관 정보와의 관계. 사용자가 삭제되면 연관된 생활 습관 정보도 삭제됨.
  @Relationship(deleteRule: .cascade) var userLifeStyle: UserLifeStyle?
  
  /// 가장 최근에 기록된 사용자의 신체 프로필을 반환함.
  var currentProfile: UserProfile? {
    userProfiles.sorted { $0.createdAt > $1.createdAt }.first
  }
  
  /// 새로운 `User` 인스턴스를 생성하고 초기화함.
  /// - Parameters:
  ///   - id: 사용자의 고유 UUID. 기본값으로 새로운 UUID가 생성됨.
  ///   - name: 사용자의 실명.
  ///   - birthDate: 사용자의 생년월일.
  ///   - gender: 사용자의 성별.
  ///   - displayName: 앱에서 사용할 별명.
  init(id: UUID = UUID(), name: String, birthDate: Date, gender: String, displayName: String) {
    self.id = id
    self.name = name
    self.birthDate = birthDate
    self.gender = gender
    self.displayName = displayName
  }
}
