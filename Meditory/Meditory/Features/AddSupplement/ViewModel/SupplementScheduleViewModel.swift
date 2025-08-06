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
  @Published var selectedHour = 1
  @Published var selectedMinute = 1
}
