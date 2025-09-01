//
//  CalendarDateModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 달력 관련 공통 유틸리티를 제공하는 모델입니다.
/// - 역할:
///   - 특정 날짜의 월 시작일, 오늘 여부, 동일 일/월 여부 등을 판별합니다.
///   - 월간 달력 그리드를 생성할 때 필요한 날짜 배열을 계산합니다.
/// - 특징:
///   - 내부적으로 `Calendar.current`를 사용합니다.
///   - 달력은 월요일 시작 기준으로 구성됩니다.
struct CalendarDateModel {
  /// 달력 계산에 사용하는 Calendar 인스턴스
  let calendar: Calendar = .current
  
  /// 주어진 날짜가 속한 달의 시작일(1일 00:00)을 반환합니다.
  /// - Parameter date: 기준 날짜
  /// - Returns: 해당 월의 시작일. 계산 불가 시 입력 값을 반환합니다.
  func startOfMonth(_ date: Date) -> Date {
    calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
  }
  
  /// 두 날짜가 같은 날인지 비교합니다.
  /// - Parameters:
  ///   - a: 비교할 첫 번째 날짜
  ///   - b: 비교할 두 번째 날짜
  /// - Returns: 두 날짜가 같은 연·월·일을 가질 경우 `true`
  func isSameDay(_ a: Date, _ b: Date) -> Bool {
    calendar.isDate(a, inSameDayAs: b)
  }
  
  /// 해당 날짜가 오늘인지 여부를 반환합니다.
  /// - Parameter date: 비교할 날짜
  /// - Returns: 오늘일 경우 `true`
  func isToday(_ date: Date) -> Bool {
    calendar.isDateInToday(date)
  }
  
  /// 두 날짜가 같은 월인지 비교합니다.
  /// - Parameters:
  ///   - date: 비교할 날짜
  ///   - baseMonth: 기준 월
  /// - Returns: 같은 연·월에 속하면 `true`
  func isSameMonth(_ date: Date, baseMonth: Date) -> Bool {
    calendar.isDate(date, equalTo: baseMonth, toGranularity: .month)
  }
  
  /// 특정 달의 달력 그리드(월요일 시작)를 생성합니다.
  /// - Parameter base: 기준 날짜 (이 달을 기준으로 달력 생성)
  /// - Returns: 한 달치 날짜 배열 (앞쪽 공백 포함, 각 날짜는 자정 기준으로 정규화됨)
  ///
  /// - 동작 방식:
  ///   1. `base`가 속한 달의 일(day) 범위를 구합니다.
  ///   2. 달의 시작일(1일)을 계산합니다.
  ///   3. 달의 시작 요일을 기준으로 월요일부터 시작하도록 앞쪽에 공백(이전 달 날짜)을 추가합니다.
  ///   4. 총 일수 + 앞쪽 공백 수 만큼의 날짜 배열을 생성합니다.
  func daysInMonthGrid(_ base: Date) -> [Date] {
    guard let range = calendar.range(of: .day, in: .month, for: base) else { return [] }
    
    let firstDay = startOfMonth(base)
    let weekday = calendar.component(.weekday, from: firstDay) // 1(일)~7(토)
    let lead = (weekday + 5) % 7  // 월요일 시작을 위한 앞쪽 공백 수
    
    let total = range.count + lead
    return (0..<total).compactMap { offset in
      calendar.date(byAdding: .day, value: offset - lead, to: firstDay)
    }
    .map { calendar.startOfDay(for: $0) }
  }
}
