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
  var showDeleteAlert = false

  // 표시용 DTO 생성기 (순수 함수)
  @MainActor
  func makeSupplementDetailInfo(from routine: Routine) -> SupplementDetailInfo {
    // 1) 시간 문자열
    let userTimes = Self.makeUserTimes(from: routine)
    // 2) 주기 문자열
    let userCycle = Self.makeUserCycle(from: routine)
    // 3) 1회 복용량(정수) 배열
    let pills = Self.makePills(from: routine)
    // 4) 메모/가이드
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

  // MARK: - 순수 계산 유틸들(정적 함수)
  static func makeUserTimes(from routine: Routine) -> [String] {
    let user = routine.routineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }
    if !user.isEmpty { return user }

    let rec = routine.recommendedRoutineTimes
      .sorted { $0.time < $1.time }
      .map { $0.time.timeFormatter }
    if !rec.isEmpty { return rec }

    // 기본값 09:00
    let nineAM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    return [nineAM.timeFormatter]
  }

  static func makeUserCycle(from routine: Routine) -> String {
    let rendered = RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)
    return rendered.isEmpty ? "매일" : rendered
  }

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

  @MainActor
  func deleteByIDs(
    pid: PersistentIdentifier,
    uuid: UUID,
    viewContext: ModelContext
  ) async {
    // Store에서 삭제
    await RoutineStore.shared.deleteRoutine(id: pid)

    // 알림 정리 및 재스케줄은 뷰 컨텍스트에서 수행
    NotificationManager.shared.cancelForRoutineID(uuid)
    await RoutineNotificationScheduler().scheduleAll(modelContext: viewContext)
    NotificationCenter.default.post(name: .didUpdateSupplement, object: nil)
  }

  @MainActor
  func delete(_ routine: Routine, in context: ModelContext) async {
    await deleteByIDs(pid: routine.persistentModelID, uuid: routine.id, viewContext: context)
  }

  func validate(_ routine: Routine) -> Bool { true }
}
