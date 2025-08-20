//
//  DateFormatter+Extension.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

extension DateFormatter {
  static func plainStringToDate(plainString:String) -> (String, Date?) {
    if let date = plainString.wholeMatch(of: /(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})/) {
      let output = date.output
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
      formatter.dateFormat = "yyyyMMdd"
      let formattedDate = "\(output.year).\(output.month).\(output.day)"
      return (formattedDate,formatter.date(from: plainString))
    } else {
      return ("날짜형식이 잘못되었습니다.",nil)
    }
  }
}
