//
//  CalendarDateModelTests.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import XCTest
@testable import Meditory

/// 월 시작/그리드/동일월·동일일자 메서드 테스트
final class CalendarDateModelTests: XCTestCase {
  private var cal: Calendar!
  private var model: CalendarDateModel!

  override func setUp() {
    super.setUp()
    var c = Calendar(identifier: .iso8601)
    c.locale = Locale(identifier: "ko_KR")
    c.timeZone = TimeZone(secondsFromGMT: 9 * 3600)!
    cal = c
    model = CalendarDateModel()
  }

  private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
    let comp = DateComponents(calendar: cal, year: y, month: m, day: d)
    return cal.date(from: comp)!
  }

  /// 입력된 날짜를 해당 달의 1일 00:00으로 잘라주는지 검증
  func test_startOfMonth_TruncatesToFirstDay() {
    // 2025-08-26 → 2025-08-01
    let src = day(2025, 8, 26)
    let first = model.startOfMonth(src)
    let comp = cal.dateComponents([.year, .month, .day], from: first)
    XCTAssertEqual(comp.year, 2025)
    XCTAssertEqual(comp.month, 8)
    XCTAssertEqual(comp.day, 1)
  }

  /// 두 날짜가 같은 달에 속하는지 올바르게 판별하는지 검증
  func test_isSameMonth() {
    let a = day(2025, 8, 15)
    let b = day(2025, 8, 31)
    let c = day(2025, 9, 1)
    XCTAssertTrue(model.isSameMonth(a, baseMonth: b))
    XCTAssertFalse(model.isSameMonth(c, baseMonth: b))
  }

  /// 같은 날짜(연/월/일)라면 시각이 달라도 true를 반환하는지 검증
  func test_isSameDay_TrueWhenSameCalendarDay() {
    let a = day(2025, 8, 15)
    // 같은 날 22:30
    let comp = DateComponents(calendar: cal, year: 2025, month: 8, day: 15, hour: 22, minute: 30)
    let b = cal.date(from: comp)!
    XCTAssertTrue(model.isSameDay(a, b))
  }

  /// 월요일 시작 기준으로 올바른 날짜 배열을 생성하는지 검증
  /// - 케이스: 2025-09-01은 월요일 → lead = 0, 총 30일
  func test_daysInMonthGrid_MondayFirstLead_CorrectCountAndFirstCell() {
    let base = day(2025, 9, 15)
    let grid = model.daysInMonthGrid(base)

    // 총 길이 = day count + lead
    XCTAssertEqual(grid.count, 30)

    // 첫 셀은 2025-09-01
    let first = grid.first!
    let comp = cal.dateComponents([.year, .month, .day], from: first)
    XCTAssertEqual(comp.year, 2025)
    XCTAssertEqual(comp.month, 9)
    XCTAssertEqual(comp.day, 1)
  }

  /// 일요일 시작 달의 경우 앞쪽 공백(lead)을 올바르게 추가하는지 검증
  /// - 케이스: 2025-06-01은 일요일 → lead = 6, 총 30+6일
  func test_daysInMonthGrid_WithLead_FromSundayMonth() {
    let base = day(2025, 6, 10)
    let grid = model.daysInMonthGrid(base)
    XCTAssertEqual(grid.count, 30 /*days*/ + 6 /*lead*/)

    // 첫 셀은 2025-05-26 (이전 달)
    let first = grid.first!
    let comp = cal.dateComponents([.year, .month, .day], from: first)
    XCTAssertEqual(comp.year, 2025)
    XCTAssertEqual(comp.month, 5)
    XCTAssertEqual(comp.day, 26)
  }
}
