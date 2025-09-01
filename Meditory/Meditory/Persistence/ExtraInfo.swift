import Foundation
import SwiftData

/// 사용자의 추가 정보(질병, 알러지, 건강 고민 등)의 유형을 나타내는 열거형임.
enum ExtraInfoType: String, Codable, CaseIterable {
  /// 질병
  case disease
  /// 알러지
  case allergy
  /// 건강 고민
  case concern
  /// 기타
  case etc
}

/// 사용자의 추가 정보를 저장하는 SwiftData 모델 클래스임.
///
/// 질병, 알러지, 건강 고민 등 다양한 유형의 정보를 키-값 쌍으로 관리함.
@Model
final class ExtraInfo: Sendable {
  /// 정보를 고유하게 식별하는 키(예: "견과류 알러지").
  @Attribute(.unique) var key: String
  
  /// 정보에 대한 값 또는 설명(예: "땅콩 및 아몬드").
  var value: String
  
  /// `ExtraInfoType`을 원시 문자열 값으로 저장하는 private 프로퍼티임.
  private var typeRaw: String
  
  /// 정보의 유형을 나타내는 계산 프로퍼티임.
  ///
  /// `typeRaw` 값을 `ExtraInfoType` 열거형으로 변환하여 안전하게 접근할 수 있도록 함.
  var type: ExtraInfoType {
    get { ExtraInfoType(rawValue: typeRaw) ?? .disease }
    set { typeRaw = newValue.rawValue }
  }
  
  /// `ExtraInfo` 객체를 생성함.
  /// - Parameters:
  ///   - key: 정보의 고유 키.
  ///   - value: 정보의 값.
  ///   - type: 정보의 유형 (`ExtraInfoType`).
  init(key: String, value: String, type: ExtraInfoType) {
    self.key = key
    self.value = value
    self.typeRaw = type.rawValue
  }
}
