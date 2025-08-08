//
//  AddSupplementViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation

class AddSupplementViewModel: ObservableObject {
  
  struct RoutineTime {
    var time: Date
    
    var hour: Int {
      Calendar.current.component(.hour, from: time)
    }
    
    var minute: Int {
      Calendar.current.component(.minute, from: time)
    }
    
    var timeString: String {
      let period = hour >= 12 ? "오후" : "오전"
      let hourIn12 = hour % 12 == 0 ? 12 : hour % 12
      let formattedMinute = String(format: "%02d", minute)
      
      return "\(period) \(hourIn12):\(formattedMinute)"
    }
  }
  
  @Published var routine = Routine()
  
  @Published var weekdays: [Weekday: Bool] = Weekday.allCases.reduce(into: [:]) { $0[$1] = true }
  @Published var startMonth: Int = Calendar.current.component(.month, from: .now)
  @Published var startDay: Int = Calendar.current.component(.day, from: .now)
  @Published var duration: Int = 1
  @Published var routineTimes = [RoutineTime]()
  @Published var memo: String = ""
  
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
    routineTimes = [
      RoutineTime(time: makeTime(hour: 8))
    ]
  }

  func addRoutineTime() {
    if let latestRoutine = routineTimes.last {
      let hour = min(latestRoutine.hour, 23)
      let minute = latestRoutine.minute
      
      routineTimes.append(RoutineTime(time: makeTime(hour: hour + 1, minute: minute)))
    }
  }
  
  func removeRoutineTime() {
    guard routineTimes.count > 1 else { return }
    
    routineTimes.removeLast()
  }
  
  func makeTime(hour: Int, minute: Int = .zero) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute

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
      routineTimes[index].time = time
    }
  }
}
