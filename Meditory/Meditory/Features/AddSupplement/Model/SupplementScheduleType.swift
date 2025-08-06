//
//  SupplementScheduleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation

enum SupplementScheduleType: String, CaseIterable, Identifiable {
  var id: String { rawValue }
  
  case weekday = "요일별"
  case interval = "주기별"
}
