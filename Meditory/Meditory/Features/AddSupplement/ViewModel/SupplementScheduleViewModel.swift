//
//  SupplementScheduleViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

class SupplementScheduleViewModel: ObservableObject {
  
  @Published var days: [Weekday: Bool] = Weekday.allCases.reduce(into: [:]) { $0[$1] = true }
  
  @Published var month = Calendar.current.component(.month, from: .now)
  @Published var day = Calendar.current.component(.day, from: .now)
  var daysInMonth: Range<Int> {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = calendar.component(.year, from: .now)
    components.month = month
    
    if let date = calendar.date(from: components),
       let range = calendar.range(of: .day, in: .month, for: date) {
      return range
    }
    
    return 1..<32
  }
  
  @Published var duration = 1
  
  @Published var time: Date = .now
  @Published var pillsPerDose = 1
  
  func selectedDayToggle(weekDay: Weekday) {
    days[weekDay]?.toggle()
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
      return month - 1
    case .day:
      return day - 1
    case .duration:
      return duration - 1
    default:
      return 0
    }
  }
  
  func setValue(for row: Int, type: SchedulePickerType) {
    switch type {
    case .month:
      self.month = row + 1
    case .day:
      let day = Array(daysInMonth)[row]
      self.day = day
    case .duration:
      self.duration = row + 1
    default:
      break
    }
  }
  
  func setPillPerDose(type: CircleIconButton.ButtonType) {
    switch type {
    case .plus:
      pillsPerDose += 1
    case .minus:
      guard pillsPerDose > 1 else { return }
      pillsPerDose -= 1
    }
  }
}
