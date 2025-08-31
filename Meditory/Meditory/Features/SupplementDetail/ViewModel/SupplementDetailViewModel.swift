//
//  SupplementDetailViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation
import SwiftUI
import SwiftData

/// 보조제 상세 화면 뷰모델
/// - 역할:
///   - `Routine` 엔티티를 기반으로 뷰에서 바로 사용할 수 있는
///     가공 데이터(`SupplementDetailInfo`)를 생성합니다.
///   - 루틴 삭제와 같은 도메인 액션을 수행하며,
///     알림 스케줄 및 뷰 갱신 이벤트를 처리합니다.
/// - 특징:
///   - 대부분의 계산 로직을 **순수 함수**(정적 메서드)로 제공하여
///     테스트 용이성과 재사용성을 높임.
///   - SwiftData `ModelContext`를 활용하여 루틴 삭제 및 상태 동기화를 관리.
///   - 삭제 시 `NotificationManager`, `RoutineNotificationScheduler`와 연계하여
///     알림 예약을 정리하고 UI에 이벤트를 브로드캐스트합니다.
@Observable
final class SupplementDetailViewModel {
  /// 삭제 확인 알림 표시 여부
  var showDeleteAlert = false
  
  // MARK: - DTO 생성
  
  /// 주어진 `Routine`으로부터 화면 표시용 `SupplementDetailInfo` 생성
  /// - 포함 정보:
  ///   - 복용 시간(`userTimes`)
  ///   - 복용 주기(`userCycle`)
  ///   - 1회 복용량(`pills`)
  ///   - 메모, 복용 가이드, 주의사항
  @MainActor
  func makeSupplementDetailInfo(from routine: Routine) -> SupplementDetailInfo {
    let userTimes = Self.makeUserTimes(from: routine)
    let userCycle = Self.makeUserCycle(from: routine)
    let pills = Self.makePills(from: routine)
    let memo = routine.memo ?? ""
    let usage = routine.usage
    let precautions = routine.precautions
    
    return SupplementDetailInfo(
      userTimes: userTimes,
      userCycle: userCycle,
      pills: pills,
      memo: memo,
      usage: usage,
      precautions: precautions
    )
  }
  
  // MARK: - 순수 계산 유틸
  
  /// 사용자 지정 루틴 시간 → 문자열 배열
  /// - 없으면 추천 시간 사용, 그래도 없으면 09:00 기본값
  static func makeUserTimes(from routine: Routine) -> [String] {
    let user = routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }
    if !user.isEmpty { return user }
    
    let rec = routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }
    if !rec.isEmpty { return rec }
    
    let nineAM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    return [nineAM.timeFormatter]
  }
  
  /// 복용 주기 문자열 렌더링
  /// - 비어있으면 기본값 `"매일"`
  static func makeUserCycle(from routine: Routine) -> String {
    let rendered = RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)
    return rendered.isEmpty ? "매일" : rendered
  }
  
  /// 1회 복용량 배열
  /// - 없으면 추천 시간 참조, 그래도 없으면 기본값 `"1정"`
  static func makePills(from routine: Routine) -> [String] {
    let user = routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { "\($0.pillsPerDose)정" }
    if !user.isEmpty { return user }
    
    let rec = routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { "\($0.pillsPerDose)정" }
    return rec.isEmpty ? ["1정"] : rec
  }
  
  // MARK: - 도메인 액션
  
  /// 루틴 삭제 (ID 기반)
  /// - RoutineStore에서 삭제
  /// - 해당 루틴 관련 알림 제거
  /// - 모든 루틴 알림 재스케줄
  /// - `.didUpdateSupplement` 알림 발송
  @MainActor
  func deleteByIDs(
    pid: PersistentIdentifier,
    uuid: UUID,
    viewContext: ModelContext
  ) async {
    await RoutineStore.shared.deleteRoutine(id: pid)
    NotificationManager.shared.cancelForRoutineID(uuid)
    await RoutineNotificationScheduler().scheduleAll()
    NotificationCenter.default.post(name: .didUpdateSupplement, object: nil)
  }
  
  /// 루틴 삭제 (엔티티 직접 전달)
  @MainActor
  func delete(_ routine: Routine, in context: ModelContext) async {
    await deleteByIDs(pid: routine.persistentModelID, uuid: routine.id, viewContext: context)
  }
  
  /// 루틴 유효성 검증 (추후 확장 예정)
  func validate(_ routine: Routine) -> Bool { true }
}
