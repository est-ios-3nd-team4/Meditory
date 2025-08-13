//
//  DateFormatter+Extension.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

extension DateFormatter {
  static func plainStringToDate(plainString:String) -> (String, Date?) {
    let year = plainString.prefix(4)
    let month = plainString.dropFirst(4).prefix(2)
    let day = plainString.dropFirst(6).prefix(2)
    let parsedDate = "\(year).\(month).\(day)"
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy.MM.dd"
    return (parsedDate,formatter.date(from: parsedDate))
  }
}
