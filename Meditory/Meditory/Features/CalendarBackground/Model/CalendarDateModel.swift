//
//  CalendarDateModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//


import SwiftUI

/// 달력 공통 유틸
struct CalendarDateModel {
  let calendar: Calendar = .current

  func startOfMonth(_ date: Date) -> Date {
    calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
  }

  func isSameDay(_ a: Date, _ b: Date) -> Bool {
    calendar.isDate(a, inSameDayAs: b)
  }

  func isToday(_ date: Date) -> Bool {
    calendar.isDateInToday(date)
  }

  func isSameMonth(_ date: Date, baseMonth: Date) -> Bool {
    calendar.isDate(date, equalTo: baseMonth, toGranularity: .month)
  }

  /// 월요일 시작으로 한 달 달력(앞쪽 공백 포함) 생성
  func daysInMonthGrid(_ base: Date) -> [Date] {
    guard let range = calendar.range(of: .day, in: .month, for: base) else { return [] }

    let firstDay = startOfMonth(base)
    let weekday = calendar.component(.weekday, from: firstDay) // 1(일)~7(토)
    let lead = (weekday + 5) % 7  // 월요일 시작을 위한 앞쪽 공백 수

    let total = range.count + lead
    return (0..<total).compactMap { offset in
      calendar.date(byAdding: .day, value: offset - lead, to: firstDay)
    }.map { calendar.startOfDay(for: $0) }
  }
}
