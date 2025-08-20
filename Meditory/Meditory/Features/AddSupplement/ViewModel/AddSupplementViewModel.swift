//
//  AddSupplementViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation
import SwiftData

class AddSupplementViewModel: ObservableObject {
  
  @Published var weekdays: [Weekday: Bool] = Weekday.allCases.reduce(into: [:]) { $0[$1] = true }
  @Published var startMonth: Int = Calendar.current.component(.month, from: .now)
  @Published var startDay: Int = Calendar.current.component(.day, from: .now)
  @Published var duration: Int = 1
  @Published var doseSchedules = [SupplementDoseSchedule]()
//  @Published var memo: String = ""
  @Published var supplemtSummary: SupplementSummary?

  private var context: ModelContext?
  
  var weekdaysString: String {
    let selected = weekdays.filter({ $0.value == true })
    
    if selected.count == 7 {
      return "매일"
    }
    
    return selected
       .map { $0.key }
       .sorted { $0.rawValue < $1.rawValue }
       .map { $0.subTitle }
       .joined(separator: ", ")
  }
  
  init() {
    doseSchedules = [
      SupplementDoseSchedule(time: Date.makeTime(hour: 8), pillsPerDose: 1)
    ]
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
    case .time(let time, let pillsPerDose):
      doseSchedules[index].time = time
      doseSchedules[index].pillsPerDose = pillsPerDose
      
      doseSchedules.sort(by: { $0.time < $1.time })
    }
  }
}


// MARK: - DB
extension AddSupplementViewModel {
  func updateContext(_ context: ModelContext) {
    self.context = context
  }
  
  @MainActor
  func saveRoutine(
    type: SupplementScheduleType,
    supplement: SupplementDTO?,
    memo: String
  ) async throws {
    guard let context else { return }
    
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
        
    let routine = Routine(
      type: supplemtSummary.type,
      displayName: supplemtSummary.name,
      desc: supplemtSummary.description,
      category: supplemtSummary.category,
      cycleType: type.rawValue,
      cycleValue: type == .weekday ? weekdaysString : "\(duration)",
      startDate: .makeDate(month: startMonth, day: startDay),
      memo: memo,
      usage: usage,
      precautions: precautions,
      routineTimes: doseSchedules.map { $0.routineTime },
      recommendedRoutineTimes: recommendedRoutineTimes
    )
    
    RoutineStore().addRoutine(routine, context: context)
  }
}


// MARK: - Network
extension AddSupplementViewModel {
  func request(productNameInput: String, nameSource: SupplementNameSource) async throws {
    print("✅ 요청", Date.now)
    
    Task { @MainActor in
      self.supplemtSummary = nil
    }
    
    let prompt = SupplementSummaryPrompt.makePrompt(
      productNameInput: productNameInput,
      nameSource: nameSource
    )
    
    let response = try await AlanAPIClient().request(content: prompt)
    
    Task { @MainActor in
      self.supplemtSummary = try JSONDecoder().decode(SupplementSummary.self, from: Data(response.utf8))
      
      print("✅ 응답", Date.now)
    }
  }
}
