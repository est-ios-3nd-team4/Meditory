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
  
  var hour: Int {
    Calendar.current.component(.hour, from: self)
  }
  
  var minute: Int {
    Calendar.current.component(.minute, from: self)
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
}
