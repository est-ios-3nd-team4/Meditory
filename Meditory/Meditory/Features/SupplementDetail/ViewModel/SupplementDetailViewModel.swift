//
//  SupplementDetailViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import Foundation
import SwiftUI
import SwiftData

enum PlanTab: String, CaseIterable, Hashable { case mine = "내 일정", ai = "AI 추천" }

@MainActor
final class SupplementDetailViewModel: ObservableObject {
  private let routineStore: RoutineStore

  /// SwiftData @Model 이므로 참조 타입으로 유지
  /// - Routine이 갱신되면 아래 computed 프로퍼티들이 최신 상태를 반영
  let routine: Routine

  // State
  @Published var selectedTab: PlanTab = .mine
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
  var userTimes: [String] {
    routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }
  }

  var userCycle: String {
    RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)
  }

  // AI 추천
  var recTimes: [String] {
    routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { t in
        if let label = t.intakeTiming, !label.isEmpty { return label }  // 상대 기준은 라벨 우선
        return t.time.timeFormatter                                    // 절대 시각은 시간 표기
      }
  }

  /// 별도 추천 주기가 없다면 사용자 주기와 동일하게 노출
  var recCycle: String {
    RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)
  }

  var usage: [String] { routine.usage }
  var precautions: [String] { routine.precautions }

  func tapMine() {
    selectedTab = .mine
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  func tapAI() {
    selectedTab = .ai
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }

  func requestDelete() { showDeleteAlert = true }

  func confirmDelete(context: ModelContext) {
    routineStore.deleteRoutine(routine, context: context)
    showDeleteAlert = false
  }

  func cancelDelete() { showDeleteAlert = false }

  /// AI 추천을 내 일정에 반영하고 싶을 때 호출
  func applyRecommendationToMine(context: ModelContext) {
    // 기존 사용자 설정 시간 교체
    routine.routineTimes.removeAll()
    // 추천 시간을 그대로 복사(라벨/오프셋은 RoutineTime에 이미 담겨 있으므로 무시하지 않음)
    let cloned: [RoutineTime] = routine.recommendedRoutineTimes.map {
      RoutineTime(
        time: $0.time,
        intakeTiming: $0.intakeTiming,
        intakeOffsetMinutes: $0.intakeOffsetMinutes,
        routine: routine
      )
    }
    routine.routineTimes = cloned
    try? context.save()
  }
}
