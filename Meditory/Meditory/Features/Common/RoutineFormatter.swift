//
//  RoutineFormatter.swift
//  Meditory
//
//  Created by 윤혜주 on 8/12/25.
//

import Foundation

enum RoutineFormatter {
  static func renderCycle(cycleType: Int, cycleValue: String) -> String {
    switch cycleType {
    case 1:
      // 일=0, 월=1, 화=2, 수=3, 목=4, 금=5, 토=6
      let map = ["일", "월", "화", "수", "목", "금", "토"]
      let days = cycleValue
        .split(whereSeparator: { String.separatorCommaSpace.contains($0) })
        .compactMap { Int($0) }
        .compactMap { (0...6).contains($0) ? map[$0] : nil }

      if days.count == 7 { return "매일" }
      if days.count == 1 { return "매주 \(days[0])요일" }
      return days.isEmpty ? "설정 없음" : days.joined(separator: "·")

    case 2:
      if let intervalDays = Int(cycleValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
        return "\(intervalDays)일 간격"
      }
      return "주기별"

    default:
      return "설정 없음"
    }
  }

  /// "0,1,3" 형식의 요일 토큰 배열(Int)로 파싱
  static func parseWeekdayTokens(_ cycleValue: String) -> [Int] {
    cycleValue
      .split(whereSeparator: { ", ".contains($0) })
      .compactMap { Int($0) }
  }

  /// 일=0, 월=1, ... 토=6  →  UNCalendar weekday(1=일 ... 7=토)
  static func unCalendarWeekdays(from cycleValue: String) -> [Int] {
    parseWeekdayTokens(cycleValue)
      .compactMap { $0 == 0 ? 1 : ($0 >= 1 && $0 <= 6 ? $0 + 1 : nil) }
      .sorted()
  }

  /// "11" → 내부 보정 규칙 (-10, 최소 1) 적용하여 실제 간격일 반환
  /// 예: "11" → 1일 간격, "14" → 4일 간격
  static func intervalDays(from cycleValue: String) -> Int? {
    let raw = Int(cycleValue.trimmingCharacters(in: .whitespacesAndNewlines))
    guard let v = raw else { return nil }
    return max(1, v - 10)
  }

  /// 알림 ID 규칙(주기별/요일별) 통일: 충돌 방지 & 재스케줄 시 정리 용이
  static func weeklyNotificationID(routineID: UUID, unCalWeekday: Int, hhmm: String) -> String {
    "routine-\(routineID.uuidString)-w\(unCalWeekday)-\(hhmm)"
  }

  static func oneOffNotificationID(routineID: UUID, date: Date, calendar: Calendar) -> String {
    let yyyymmdd = date.formattedString("yyyyMMdd", calendar: calendar)
    let hhmm     = date.formattedString("HHmm", calendar: calendar)
    return "routine-\(routineID.uuidString)-\(yyyymmdd)-\(hhmm)"
  }
}
