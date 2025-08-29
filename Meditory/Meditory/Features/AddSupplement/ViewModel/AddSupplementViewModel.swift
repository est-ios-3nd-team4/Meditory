//
//  AddSupplementViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation
import SwiftData
import UserNotifications

@Observable
final class AddSupplementViewModel {
  
  var weekdays: [Weekday: Bool]
  var startMonth: Int
  var startDay: Int
  var duration: Int
  var doseSchedules = [SupplementDoseSchedule]()
  var supplemtSummary: SupplementSummary?
  var supplement: SupplementDTO?
  var routineId: UUID?
  var memo: String
  var selectedScheduleType: SupplementScheduleType

  var weekdaysString: String {
    let selected = weekdays.filter({ $0.value == true })

    if selected.count == 7 {
      return "매일"
    }

    return selected
      .map { $0.key }
      .sorted { $0.rawValue < $1.rawValue }
      .map { $0.subTitle }
      .joined(separator: .separatorCommaSpace)
  }

  var formattedWeekdays: String {
    return weekdays.filter({ $0.value == true })
      .map { $0.key }
      .sorted { $0.rawValue < $1.rawValue }
      .map { "\($0.rawValue)" }
      .joined(separator: .separatorCommaSpace)
  }

  init(routine: Routine? = nil) {
    startMonth = Date.now.month
    startDay = Date.now.day
    duration = 1
    doseSchedules = [SupplementDoseSchedule]()
    memo = ""
    selectedScheduleType = .weekday

    if let routine {
      routineId = routine.id
      weekdays = Weekday.allCases.reduce(into: [:]) { $0[$1] = false }
      initialize(with: routine)
    } else {
      weekdays = Weekday.allCases.reduce(into: [:]) { $0[$1] = true }
      doseSchedules = [
        SupplementDoseSchedule(time: Date.makeTime(hour: 8), pillsPerDose: 1)
      ]
    }
  }

  func initialize(with routine: Routine) {
    let scheduleType = SupplementScheduleType(rawValue: routine.cycleType)

    selectedScheduleType = scheduleType ?? .weekday
    memo = routine.memo ?? ""

    switch scheduleType {
    case .weekday:
      routine.cycleValue.split(separator: String.separatorCommaSpace).forEach {
        if let rawValue = Int($0),
           let weekday = Weekday(rawValue: rawValue) {
          weekdays[weekday] = true
        }
      }
    case .interval:
      duration = Int(routine.cycleValue) ?? 1
      startMonth = Int(routine.startDate.month)
      startDay = Int(routine.startDate.day)
    default: break
    }

    doseSchedules = routine.routineTimes.map {
      SupplementDoseSchedule(time: $0.time, pillsPerDose: $0.pillsPerDose)
    }
    doseSchedules.sort(by: { $0.time < $1.time })

    supplemtSummary = SupplementSummary(
      type: routine.type,
      name: routine.displayName,
      description: routine.desc ?? "",
      category: routine.category ?? "",
      usage: routine.usage,
      precautions: routine.precautions
    )

    if routine.recommendedRoutineTimes.count > 0, let scheduleType {
      let times = routine.recommendedRoutineTimes.map {
        DoseTime(
          hour: $0.time.hour,
          minute: $0.time.minute,
          relativeTo: $0.intakeTiming ?? "",
          offsetMinutes: $0.intakeOffsetMinutes ?? 0,
          pillsPerDose: $0.pillsPerDose
        )
      }

      supplement = SupplementDTO(
        schedule: DoseSchedule(
          cycleType: scheduleType,
          times: times
        ),
        usage: routine.usage,
        precautions: routine.precautions
      )
    }
  }

  func addRoutineTime() {
    if let latestRoutine = doseSchedules.last {
      let hour = min(latestRoutine.hour, 23)
      let minute = latestRoutine.minute

      doseSchedules.append(
        SupplementDoseSchedule(
          time: Date.makeTime(hour: hour + 1, minute: minute),
          pillsPerDose: 1
        )
      )
    }
  }

  func removeRoutineTime() {
    guard doseSchedules.count > 1 else { return }

    doseSchedules.removeLast()
  }

  func setValue(_ value: SchedulePickerValue, index: Int = 0) {
    switch value {
    case .month(let month):
      startMonth = month
    case .day(let day):
      startDay = day
    case .duration(let duration):
      self.duration = duration
    case .weekday(let days):
      self.weekdays = days
    case .time(let doseSchedule):
      doseSchedules[index] = doseSchedule
      doseSchedules.sort(by: { $0.time < $1.time })
    }
  }
}


// MARK: - DB
extension AddSupplementViewModel {
  @MainActor
  func saveRoutine() async throws {
    guard let supplemtSummary = supplemtSummary else { throw RoutineSaveError.supplementSummaryNotFound }
    var usage = supplemtSummary.usage
    var precautions = supplemtSummary.precautions
    var recommendedRoutineTimes: [RoutineTime] = []

    // AI 스케줄 데이터가 있을 경우 기본 제품 정보보다 우선적으로 사용함
    if let supplement {
      usage = supplement.usage
      precautions = supplement.precautions
      recommendedRoutineTimes = supplement.schedule.routineTimes
    }

    if let routineId {
      _ = try await RoutineStore.shared.updateRoutine(
        id: routineId,
        type: supplemtSummary.type,
        displayName: supplemtSummary.name,
        desc: supplemtSummary.description,
        category: supplemtSummary.category,
        cycleType: selectedScheduleType.rawValue,
        cycleValue: selectedScheduleType == .weekday ? formattedWeekdays : "\(duration)",
        startDate: .makeDate(month: startMonth, day: startDay),
        memo: memo,
        usage: usage,
        precautions: precautions,
        routineTimes: doseSchedules.map { $0.routineTime },
        recommendedRoutineTimes: recommendedRoutineTimes
      )
    } else {
      _ = try await RoutineStore.shared.createRoutine(
        type: supplemtSummary.type,
        displayName: supplemtSummary.name,
        desc: supplemtSummary.description,
        category: supplemtSummary.category,
        cycleType: selectedScheduleType.rawValue,
        cycleValue: selectedScheduleType == .weekday ? formattedWeekdays : "\(duration)",
        startDate: .makeDate(month: startMonth, day: startDay),
        memo: memo,
        usage: usage,
        precautions: precautions,
        routineTimes: doseSchedules.map { $0.routineTime },
        recommendedRoutineTimes: recommendedRoutineTimes
      )
    }
  }

  /// 편집/신규 추가 모두 처리. 편집 시 기존 인스턴스를 덮어쓰기.
  @MainActor
  func saveAndEditRoutine(
    modelContext context: ModelContext,
    editingRoutine: Routine?
  ) async throws {
    try await saveRoutine()

    await RoutineNotificationScheduler().scheduleAll(modelContext: context)

    NotificationCenter.default.post(name: .didUpdateSupplement, object: nil)
  }
}


// MARK: - Network
extension AddSupplementViewModel {
  func request(productNameInput: String, nameSource: SupplementNameSource) async throws {

    await MainActor.run {
      self.supplemtSummary = nil
    }
    
    let prompt = SupplementSummaryPrompt.makePrompt(
      productNameInput: productNameInput,
      nameSource: nameSource
    )

    let response = try await AlanAPIClient().request(content: prompt)

    await MainActor.run {
      self.supplemtSummary = try? JSONDecoder().decode(SupplementSummary.self, from: Data(response.utf8))
    }

  }
}
