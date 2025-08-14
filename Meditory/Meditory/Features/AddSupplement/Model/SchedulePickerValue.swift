//
//  SchedulePickerValue.swift
//  Meditory
//
//  Created by 홍승아 on 8/8/25.
//

import Foundation

enum SchedulePickerValue {
  case month(Int)
  case day(Int)
  case duration(Int)
  case weekday([Weekday: Bool])
  case time(Date, Int)
}
