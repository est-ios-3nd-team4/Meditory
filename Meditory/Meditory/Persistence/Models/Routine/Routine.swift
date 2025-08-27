import Foundation
import SwiftData

/// 복용 주기 정보를 저장하는 데이터 모델
@Model
final class Routine: Sendable {
  /// 루틴 고유 식별자 (UUID)
  @Attribute(.unique) var id: UUID
  
  /// 루틴 유형
  /// - 1: 영양제
  /// - 2: 약
  var type: Int
  
  /// 루틴 이름 (표시용)
  /// - 사용자가 직접 입력한 명칭
  /// - 예: "오메가", "아침 비타민", "리포좀 멀티비타민"
  /// - UI 목록·알림 등에 그대로 표시
  var displayName: String
  
  /// 루틴 설명 (선택 사항)
  var desc: String?
  
  /// 루틴 카테고리(표준화된 분류)
  /// - 검색/필터/통계용 내부 분류 값
  /// - 예: "오메가3", "종합비타민", "프로바이오틱스"
  /// - 사용자가 입력한 displayName과 다를 수 있음
  var category: String?
  
  /// 복용 주기 유형
   /// - 1: 요일별
   /// - 2: 주기별
  var cycleType: Int
  
  /// 복용 주기 값
  /// - 요일별: 0~6 (일~토)
  /// - 주기별: 11~19 (1일~9일 간격)
  /// - 예: "0,2,4" → 일·화·목
  var cycleValue: String  // 0~6: 일~토, 11~19: 1일~9일 간격
  
  /// 루틴 시작 날짜
  var startDate: Date
  
  /// 메모 (예: "아침 식사 후 복용")
  var memo: String?
  
  /// 알림 여부 (true면 푸시 알림 활성화)
  var hasPush: Bool
  
  /// 제품 이미지 데이터
  var imageData: Data?

  /// 복용 방법 목록
  var usage: [String] = []
  
  /// 주의 사항 목록
  var precautions: [String] = []
  
  /// 사용자 설정 복용 시간 목록
  /// - RoutineTime과 1:N 관계
  /// - Routine 삭제 시 함께 삭제됨
  @Relationship(deleteRule: .cascade)
  var routineTimes: [RoutineTime] = []
  
  /// AI 추천 복용 시간 목록
  /// - RoutineTime과 1:N 관계
  /// - Routine 삭제 시 함께 삭제됨
  @Relationship(deleteRule: .cascade)
  var recommendedRoutineTimes: [RoutineTime] = []
  
  /// 하루 복용 횟수
  var timesPerDay: Int {
    routineTimes.count
  }
  
  init(
    id: UUID = UUID(),
    type: Int,
    displayName: String,
    desc: String? = nil,
    category: String? = nil,
    cycleType: Int,
    cycleValue: String,
    startDate: Date = .now,
    memo: String? = nil,
    hasPush: Bool = true,
    imageData: Data? = nil,
    usage: [String] = [],
    precautions: [String] = [],
    routineTimes: [RoutineTime] = [],
    recommendedRoutineTimes: [RoutineTime] = []
  ) {
    self.id = id
    self.type = type
    self.displayName = displayName
    self.desc = desc
    self.category = category
    self.cycleType = cycleType
    self.cycleValue = cycleValue
    self.startDate = startDate
    self.memo = memo
    self.hasPush = hasPush
    self.imageData = imageData
    self.usage = usage
    self.precautions = precautions
    self.routineTimes = routineTimes
    self.recommendedRoutineTimes = recommendedRoutineTimes
  }
}
