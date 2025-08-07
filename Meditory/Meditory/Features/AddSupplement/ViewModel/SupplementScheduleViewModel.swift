//
//  SupplementScheduleViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

class SupplementScheduleViewModel: ObservableObject {
  
  @Published var selectedDays: [Weekday: Bool] = Weekday.allCases.reduce(into: [:]) { $0[$1] = false }
  
  @Published var selectedMonth = Calendar.current.component(.month, from: .now)
  @Published var selectedDay = Calendar.current.component(.day, from: .now)
  var daysInMonth: Range<Int> {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = calendar.component(.year, from: .now)
    components.month = selectedMonth
    
    if let date = calendar.date(from: components),
       let range = calendar.range(of: .day, in: .month, for: date) {
      return range
    }
    
    return 1..<32
  }
  
  @Published var selectedDuration = 1
  
  @Published var selectedMeridiem: Meridiem = .am
  @Published var selectedTime: Date = .now
  
  func selectedDayToggle(weekDay: Weekday) {
    selectedDays[weekDay]?.toggle()
  }
  
  func numberOfRows(for type: SchedulePickerType) -> Int {
    switch type {
    case .month:
      return 12
    case .day:
      return daysInMonth.count
    case .duration:
      return 100
    default:
      return 0
    }
  }
  
  func title(for row: Int, type: SchedulePickerType) -> String {
    switch type {
    case .month:
      return "\(row + 1)"
    case .day:
      let day = Array(daysInMonth)[row]
      return "\(day)"
    case .duration:
      return "\(row + 1)"
    default:
      return ""
    }
  }
  
  func content(for row: Int, type: SchedulePickerType) -> String {
    switch type {
    case .month:
      return "\(row + 1)"
    case .day:
      let day = Array(daysInMonth)[row]
      return "\(day)"
    case .duration:
      return "\(row + 1)"
    default:
      return ""
    }
  }
  
  func index(type: SchedulePickerType) -> Int {
    switch type {
    case .month:
      return selectedMonth - 1
    case .day:
      return selectedDay - 1
    case .duration:
      return selectedDuration - 1
    default:
      return 0
    }
  }
  
  func setValue(type: SchedulePickerType, vm: SupplementScheduleViewModel) {
    switch type {
    case .month:
      self.selectedMonth = vm.selectedMonth
    case .day:
      self.selectedDay = vm.selectedDay
    case .duration:
      self.selectedDuration = vm.selectedDuration
    default:
      break
    }
  }
  
  func setValue(for row: Int, type: SchedulePickerType) {
    switch type {
    case .month:
      self.selectedMonth = row + 1
    case .day:
      let day = Array(daysInMonth)[row]
      self.selectedDay = day
    case .duration:
      self.selectedDuration = row + 1
    default:
      break
    }
  }
}
