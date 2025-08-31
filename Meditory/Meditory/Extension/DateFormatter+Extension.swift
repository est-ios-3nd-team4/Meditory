//
//  DateFormatter+Extension.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//

import Foundation

/// `DateFormatter` 확장
/// - 문자열 `"yyyyMMdd"` 형식을 사람이 읽을 수 있는 `"yyyy.MM.dd"` 포맷으로 변환하고,
///   동시에 `Date` 객체로 파싱할 수 있는 유틸리티를 제공합니다.
extension DateFormatter {
  /// `"yyyyMMdd"` 형식 문자열을 `"yyyy.MM.dd"`로 변환하고 `Date` 객체로 반환
  /// - Parameters:
  ///   - plainString: 변환할 문자열 (예: `"20250807"`)
  /// - Returns: `(포맷된 문자열, Date 객체)`
  ///   - 변환 성공 시: (`"2025.08.07"`, `Date?`)
  ///   - 변환 실패 시: (`"날짜형식이 잘못되었습니다."`, `nil`)
  ///
  /// - Example:
  ///   ```swift
  ///   let result = DateFormatter.plainStringToDate(plainString: "20250807")
  ///   print(result.0) // "2025.08.07"
  ///   print(result.1) // Optional(2025-08-07 00:00:00 +0000)
  ///   ```
  static func plainStringToDate(plainString: String) -> (String, Date?) {
    if let date = plainString.wholeMatch(of: /(?<year>\d{4})(?<month>\d{2})(?<day>\d{2})/) {
      let output = date.output
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
      formatter.dateFormat = "yyyyMMdd"
      let formattedDate = "\(output.year).\(output.month).\(output.day)"
      return (formattedDate, formatter.date(from: plainString))
    } else {
      return ("날짜형식이 잘못되었습니다.", nil)
    }
  }
}
