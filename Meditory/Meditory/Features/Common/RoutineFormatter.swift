//
//  RoutineFormatter.swift
//  Meditory
//
//  Created by 윤혜주 on 8/12/25.
//

import Foundation

/// 루틴의 반복 주기(cycle)와 관련된 **표현/파싱/ID 생성 유틸리티**입니다.
/// - 주요 기능:
///   - 반복 주기(cycleType, cycleValue)를 사용자 친화적인 문자열로 변환
///   - 요일 토큰 파싱 및 `UNCalendar`용 요일 변환
///   - 간격일(interval) 계산
///   - 알림(Notification) ID 생성 규칙 제공
enum RoutineFormatter {
  /// 루틴 반복 주기를 문자열로 변환합니다.
  /// - Parameters:
  ///   - cycleType: 반복 주기 타입
  ///     - `1`: 요일별 (예: 월, 수, 금)
  ///     - `2`: 주기별 (예: 2일 간격)
  ///   - cycleValue: 주기 값 (예: `"0,1,2"`, `"2"`, `"11"` 등)
  /// - Returns: 사용자에게 표시할 문자열 (예: `"매일"`, `"매주 화요일"`, `"월·수·금"`, `"2일 간격"`)
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
  
  /// 요일 토큰 문자열을 배열(Int)로 파싱합니다.
  /// - Parameter cycleValue: `"0,1,3"` 형식의 문자열
  /// - Returns: 요일 배열 (예: `[0, 1, 3]`)
  static func parseWeekdayTokens(_ cycleValue: String) -> [Int] {
    cycleValue
      .split(whereSeparator: { ", ".contains($0) })
      .compactMap { Int($0) }
  }
  
  /// 내부 요일 인덱스(일=0, 월=1, ... 토=6)를
  /// UNCalendar weekday(1=일 ~ 7=토) 형식으로 변환합니다.
  /// - Parameter cycleValue: `"0,1,3"` 형식의 문자열
  /// - Returns: UNCalendar weekday 배열 (예: `[1, 2, 4]`)
  static func unCalendarWeekdays(from cycleValue: String) -> [Int] {
    parseWeekdayTokens(cycleValue)
      .compactMap { $0 == 0 ? 1 : ($0 >= 1 && $0 <= 6 ? $0 + 1 : nil) }
      .sorted()
  }
  
  /// 주기별 복용 주기의 "간격일"을 계산합니다.
  /// - 내부 규칙:
  ///   - `"11"` → `1일 간격`
  ///   - `"14"` → `4일 간격`
  ///   - 10을 뺀 값, 최소 1 보정
  /// - Parameter cycleValue: 주기 값 문자열
  /// - Returns: 계산된 간격일(Int), 변환 불가 시 `nil`
  static func intervalDays(from cycleValue: String) -> Int? {
    let raw = Int(cycleValue.trimmingCharacters(in: .whitespacesAndNewlines))
    guard let v = raw else { return nil }
    return max(1, v - 10)
  }
  
  /// 요일별 루틴 알림 ID를 생성합니다.
  /// - 규칙: `"routine-{routineID}-w{weekday}-{hhmm}"`
  /// - Parameters:
  ///   - routineID: 루틴 고유 ID
  ///   - unCalWeekday: UNCalendar 기준 요일 (1=일 ~ 7=토)
  ///   - hhmm: "HHmm" 형식의 시간 문자열
  /// - Returns: 고유 알림 ID
  static func weeklyNotificationID(routineID: UUID, unCalWeekday: Int, hhmm: String) -> String {
    "routine-\(routineID.uuidString)-w\(unCalWeekday)-\(hhmm)"
  }
  
  /// 1회성 루틴 알림 ID를 생성합니다.
  /// - 규칙: `"routine-{routineID}-{yyyymmdd}-{hhmm}"`
  /// - Parameters:
  ///   - routineID: 루틴 고유 ID
  ///   - date: 알림 날짜
  ///   - calendar: 포맷 기준 캘린더
  /// - Returns: 고유 알림 ID
  static func oneOffNotificationID(routineID: UUID, date: Date, calendar: Calendar) -> String {
    let yyyymmdd = date.formattedString("yyyyMMdd", calendar: calendar)
    let hhmm     = date.formattedString("HHmm", calendar: calendar)
    return "routine-\(routineID.uuidString)-\(yyyymmdd)-\(hhmm)"
  }
}
