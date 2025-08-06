//
//  AddSupplementViewModel.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation

class AddSupplementViewModel: ObservableObject {
  
  struct RoutineTime {
    let hour: Int
    let minute: Int
    var weekdays = [0, 1, 2, 3, 4, 5, 6]
    var startDate: Date = .now
    var cycleValue: Int?
    
    var timeString: String {
      let period = hour >= 12 ? "오후" : "오전"
      let hourIn12 = hour % 12 == 0 ? 12 : hour % 12
      let formattedMinute = String(format: "%02d", minute)
      
      return "\(period) \(hourIn12):\(formattedMinute)"
    }
  }
  
  @Published var routine = Routine()
  @Published var routineTimes: [RoutineTime] = [
    RoutineTime(hour: 8, minute: 0)
  ]
  @Published var memo: String = ""

  func addRoutineTime() {
    if let lastRoutine = routineTimes.last {
      routineTimes.append(RoutineTime(hour: lastRoutine.hour + 1, minute: 0))
    }
  }
  
  func removeRoutineTime() {
    guard routineTimes.count > 1 else { return }
    
    routineTimes.removeLast()
  }
}
