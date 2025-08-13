//
//  String+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//

import Foundation

extension String {
  /// "HH:mm" -> 오늘 날짜의 Date (시/분만 반영)
  func toDateFromHHmm(calendar: Calendar = .current) -> Date? {
    let parts = split(separator: ":")
    guard parts.count == 2,
          let h = Int(parts[0]),
          let m = Int(parts[1]),
          (0..<24).contains(h),
          (0..<60).contains(m) else { return nil }
    var dc = calendar.dateComponents([.year, .month, .day], from: Date())
    dc.hour = h
    dc.minute = m
    dc.second = 0
    return calendar.date(from: dc)
  }

  /// "오전/오후 h:mm" (자체가 "HH:mm"일 때만 적용, 아니면 "식사 안함")
  func prettyKRFromHHmm() -> String {
    guard let d = toDateFromHHmm() else { return "식사 안함" }
    return d.timeFormatter
  }
}
