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
  @Published var times = [SupplementIntakeTime]()
  @Published var memo: String = ""
  
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
    times = [
      SupplementIntakeTime(time: makeTime(hour: 8))
    ]
  }

  func addRoutineTime() {
    if let latestRoutine = times.last {
      let hour = min(latestRoutine.hour, 23)
      let minute = latestRoutine.minute
      
      times.append(SupplementIntakeTime(time: makeTime(hour: hour + 1, minute: minute)))
    }
  }
  
  func removeRoutineTime() {
    guard times.count > 1 else { return }
    
    times.removeLast()
  }
  
  func makeTime(hour: Int, minute: Int = .zero) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute

    return Calendar.current.date(from: components) ?? Date()
  }
  
  func makeDate(month: Int, day: Int) -> Date {
    var components = Calendar.current.dateComponents([.year], from: Date())
    components.month = month
    components.day = day

    return Calendar.current.date(from: components) ?? Date()
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
    case .time(let time):
      times[index].time = time
    }
  }
}


extension AddSupplementViewModel {
  func updateContext(_ context: ModelContext) {
    self.context = context
  }
}
