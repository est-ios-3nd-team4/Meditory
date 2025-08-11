//
//  SupplementIntakeTime.swift
//  Meditory
//
//  Created by 홍승아 on 8/11/25.
//

import Foundation

struct SupplementIntakeTime {
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
