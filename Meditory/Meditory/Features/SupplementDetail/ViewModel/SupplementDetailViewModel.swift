//
//  SupplementDetailViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class SupplementDetailViewModel: ObservableObject {
  private let routineStore: RoutineStore

  /// SwiftData @Model 이므로 참조 타입으로 유지
  /// - Routine이 갱신되면 아래 computed 프로퍼티들이 최신 상태를 반영
  let routine: Routine

  // State
  @Published var showDeleteAlert: Bool = false

  // Init
  init(
    routine: Routine,
    routineStore: RoutineStore = RoutineStore()
  ) {
    self.routine = routine
    self.routineStore = routineStore
  }

  // Header
  var name: String { routine.displayName }
  var subtitle: String { routine.desc ?? "" }

  // Mine (사용자 설정)
  /// 1) 사용자 지정 시간
  /// 2) 없으면 추천 시간
  /// 3) 그래도 없으면 09:00 기본 1회
  var userTimes: [String] {
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
    let rendered = RoutineFormatter.renderCycle(
      cycleType: routine.cycleType,
      cycleValue: routine.cycleValue
    )

    if rendered.isEmpty { return "매일" }
    return rendered
  }
  var usage: [String] { routine.usage }
  var precautions: [String] { routine.precautions }

  func requestDelete() { showDeleteAlert = true }

  func confirmDelete(context: ModelContext) {
    routineStore.deleteRoutine(routine, context: context)
    showDeleteAlert = false
  }

  func cancelDelete() { showDeleteAlert = false }
}
