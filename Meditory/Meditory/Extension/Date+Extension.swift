//
//  Extension+Date.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import Foundation

extension Date {
  var timeFormatter: String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.dateFormat = "a h:mm"
    return dateFormatter.string(from: self)
  }

  var yearMonth: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy년 M월"
    return dateFormatter.string(from: self)
  }

  var year: Int {
    Calendar.current.component(.year, from: self)
  }

  var month: Int {
    Calendar.current.component(.month, from: self)
  }

  var day: Int {
    Calendar.current.component(.day, from: self)
  }

  var hour: Int {
    Calendar.current.component(.hour, from: self)
  }

  var minute: Int {
    Calendar.current.component(.minute, from: self)
  }

  static func daysInMonth(year: Int = Date().year, month: Int) -> [Int] {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = year
    components.month = month
    
    if let date = calendar.date(from: components),
       let range = calendar.range(of: .day, in: .month, for: date) {
      return range.map { Int($0) }
    }
    
    return (1...31).map { Int($0) }
  }
  
  func formattedDate(_ date: Date, _ format: String) -> String {
    let df = DateFormatter()
    df.dateFormat = format
    return df.string(from: date)
  }

  /// Date -> "HH:mm"
  func toHHmmString(calendar: Calendar = .current) -> String {
    let h = calendar.component(.hour, from: self)
    let m = calendar.component(.minute, from: self)
    return String(format: "%02d:%02d", h, m)
  }

  /// 만 나이(정수). 미래 날짜면 0으로 클램프.
  func ageYears(reference: Date = Date(), calendar: Calendar = .current) -> Int {
    let years = calendar.dateComponents([.year], from: self, to: reference).year ?? 0
    return max(0, years)
  }

  /// 나이대 문자열: 10대 이하 / 20대 / 30대 ... / 70대 이상
  func ageBandString(reference: Date = Date(), calendar: Calendar = .current) -> String {
    let years = ageYears(reference: reference, calendar: calendar)
    switch years {
    case ..<20: return "10대 이하"
    case 20..<70:
      let decade = (years / 10) * 10
      return "\(decade)대"
    default:
      return "70대 이상"
    }
  }

  static func makeTime(hour: Int, minute: Int = .zero) -> Date {
    var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    components.hour = hour
    components.minute = minute

    return Calendar.current.date(from: components) ?? Date()
  }

  static func makeDate(month: Int, day: Int) -> Date {
    var components = Calendar.current.dateComponents([.year], from: Date())
    components.month = month
    components.day = day

    return Calendar.current.date(from: components) ?? Date()
  }

  func dateFromYearString(yearString:String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter.date(from: "\(yearString)0101")
  }

  /// self(날짜)의 년/월/일 + other(시간)의 시/분/초를 결합
  func mergingTime(from other: Date, calendar: Calendar = .current) -> Date {
    var comp = calendar.dateComponents([.year, .month, .day], from: self)
    comp.hour = calendar.component(.hour, from: other)
    comp.minute = calendar.component(.minute, from: other)
    comp.second = calendar.component(.second, from: other)
    return calendar.date(from: comp) ?? self
  }

  /// 현재 시점(now) 이전이면 intervalDays만큼 증가시켜 now 이후로 끌어올림
  func advancedToNow(byDayInterval intervalDays: Int, calendar: Calendar = .current) -> Date {
    precondition(intervalDays > 0, "intervalDays must be > 0")
    var base = self
    let now  = Date()
    while base < now {
      guard let next = calendar.date(byAdding: .day, value: intervalDays, to: base) else { break }
      base = next
    }
    return base
  }

  /// self를 시작점으로 intervalDays 간격으로 occurrences회 날짜 배열 생성
  func nextDates(everyDays intervalDays: Int, occurrences: Int, calendar: Calendar = .current) -> [Date] {
    precondition(intervalDays > 0, "intervalDays must be > 0")
    guard occurrences > 0 else { return [] }
    var result: [Date] = []
    var base = self
    for _ in 0..<occurrences {
      result.append(base)
      guard let next = calendar.date(byAdding: .day, value: intervalDays, to: base) else { break }
      base = next
    }
    return result
  }

  /// 지정 포맷 문자열로 날짜를 문자열로 변환 (로케일/타임존은 캘린더 기반)
  func formattedString(_ format: String, calendar: Calendar = .current, locale: Locale = Locale(identifier: "ko_KR")) -> String {
    let df = DateFormatter()
    df.calendar = calendar
    df.locale   = locale
    df.timeZone = calendar.timeZone
    df.dateFormat = format
    return df.string(from: self)
  }
}
