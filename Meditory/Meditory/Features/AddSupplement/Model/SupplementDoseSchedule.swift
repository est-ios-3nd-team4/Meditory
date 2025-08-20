//
//  SupplementDoseSchedule.swift
//  Meditory
//
//  Created by 홍승아 on 8/14/25.
//

import Foundation

struct SupplementDoseSchedule {
  var time: Date
  var pillsPerDose: Int
  
  var hour: Int {
    time.hour
  }
  
  var minute: Int {
    time.minute
  }
  
  var doseString: String {
    "\(pillsPerDose)정"
  }
  
  var routineTime: RoutineTime {
    RoutineTime(time: .makeTime(hour: hour, minute: minute))
  }
}
