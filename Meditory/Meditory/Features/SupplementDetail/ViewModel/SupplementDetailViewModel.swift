//
//  SupplementDetailViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
final class SupplementDetailViewModel {
  /// SwiftData @Model 이므로 참조 타입으로 유지
  /// - Routine이 갱신되면 아래 computed 프로퍼티들이 최신 상태를 반영
  /// - Routine 삭제 시 nil 처리
  var routine: Routine?

  // State
  var showDeleteAlert: Bool = false

  // Init
  init(routine: Routine) {
    self.routine = routine
  }

  // Header
  var name: String { routine?.displayName ?? "" }
  var subtitle: String { routine?.desc ?? "" }

  // Mine (사용자 설정)
  /// 1) 사용자 지정 시간
  /// 2) 없으면 추천 시간
  /// 3) 그래도 없으면 09:00 기본 1회
  var userTimes: [String] {
    guard let routine else { return [] }

    let user = routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }

    if !user.isEmpty { return user }

    let recommended = routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }

    if !recommended.isEmpty { return recommended }

    let nineAM = Calendar.current.date(
      bySettingHour: 9, minute: 0, second: 0, of: Date()
    ) ?? Date()
    return [nineAM.timeFormatter]
  }

  /// 비정상(cycleType=0, value="", 포맷 실패 등)일 경우 "매일"로 대체
  var userCycle: String {
    guard let routine else { return "매일" }

    let rendered = RoutineFormatter.renderCycle(
      cycleType: routine.cycleType,
      cycleValue: routine.cycleValue
    )

    return rendered.isEmpty ? "매일" : rendered
  }

  /// 시간별 복용 알약 수 정보
  var pills: [String] {
    guard let routine else { return ["1정"] }

    // 1. 사용자 설정 복용 시간이 있는 경우
    let userPills = routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { "\($0.pillsPerDose)정" }

    if !userPills.isEmpty {
      return userPills
    }

    // 2. 사용자 설정이 없고 AI 추천 시간이 있는 경우
    let recommendedPills = routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { "\($0.pillsPerDose)정" }

    if !recommendedPills.isEmpty {
      return recommendedPills
    }

    // 3. 둘 다 없는 경우, 기본값으로 "1정" 반환
    return ["1정"]
  }

  /// 메모
  var memo: String {
    routine?.memo ?? ""
  }

  var usage: [String] { routine?.usage ?? [] }
  var precautions: [String] { routine?.precautions ?? [] }

  func requestDelete() {
    showDeleteAlert = true
  }

  @MainActor
  func confirmDelete(dismiss: DismissAction) async {
    if let routineToDelete = routine {
      await RoutineStore.shared.deleteRoutine(id: routineToDelete.persistentModelID)
      self.routine = nil
      NotificationManager.shared.cancelForRoutineID(routineToDelete.id)
    }
    showDeleteAlert = false
    dismiss()
  }

  func cancelDelete() {
    showDeleteAlert = false
  }
}
