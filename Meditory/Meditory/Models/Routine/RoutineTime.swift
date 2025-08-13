import SwiftData
import Foundation

/// 복용 시간을 저장하는 데이터 모델
@Model
final class RoutineTime {
  /// 복용 시간 고유 식별자
  @Attribute(.unique) var id: UUID
  
  /// 복용 기준 시간
  var time: Date
  
  /// 복용 시점 기준 설명
  /// - 예: "식전", "식후", "취침 전", "취침 후"
  /// - 없으면 단순 시각 기반 복용
  var relativeTo: String?
  
  /// 복용 시각의 오프셋(분 단위)
 /// - 기준 시각에서 몇 분 전/후인지
 /// - 음수: 기준 시각 이전, 양수: 이후
 /// - 예: -30 → 30분 전, +30 → 30분 후
  var offsetMinutes: Int?
  
  @Relationship var routine: Routine?
  
  init(
    id: UUID = UUID(),
    time: Date,
    relativeTo: String? = nil,
    offsetMinutes: Int? = nil,
    routine: Routine? = nil
  ) {
    self.id = id
    self.time = time
    self.relativeTo = relativeTo
    self.offsetMinutes = offsetMinutes
    self.routine = routine
  }
}
