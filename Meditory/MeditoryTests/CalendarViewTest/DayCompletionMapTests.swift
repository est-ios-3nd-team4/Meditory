//
//  DayCompletionMapTests.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import XCTest
@testable import Meditory

/// `DayCompletionMap`의 완료율 조회 로직을 검증하는 단위 테스트입니다.
/// - 검증 범위:
///   - 동일한 날짜(연/월/일)라면 시각에 관계없이 매핑된 값을 반환하는지
///   - 저장된 값이 경계값을 벗어날 경우 0.0 ~ 1.0 범위로 올바르게 클램핑되는지
///   - 매핑이 존재하지 않는 경우 기본값 0.0을 반환하는지
final class DayCompletionMapTests: XCTestCase {
  private var cal: Calendar!
  
  override func setUp() {
    super.setUp()
    var c = Calendar(identifier: .iso8601)
    c.locale = Locale(identifier: "ko_KR")
    c.timeZone = TimeZone(secondsFromGMT: 9 * 3600)! // 한국 시간대 고정
    cal = c
  }
  
  private func day(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 0, _ min: Int = 0) -> Date {
    let comp = DateComponents(calendar: cal, year: y, month: m, day: d, hour: h, minute: min)
    return cal.date(from: comp)!
  }
  
  /// 같은 달력 날짜라면 시각이 달라도 동일한 완료율 값을 반환하는지 검증합니다.
  func test_progress_ReturnsValueForSameDay_IgnoresTime() {
    let target = day(2025, 8, 18, 22, 30)
    let key = cal.startOfDay(for: target) // 2025-08-18 00:00
    let sut: DayCompletionMap = [key: 0.7]
    
    let p = sut.progress(for: target, calendar: cal)
    
    XCTAssertEqual(p, 0.7, accuracy: 0.0001)
  }
  
  /// 저장된 값이 0 미만일 경우, 최소값 0으로 클램핑되는지 검증합니다.
  func test_progress_ClampsLessThanZeroToZero() {
    let d = day(2025, 8, 18)
    let sut: DayCompletionMap = [d: -1.5]
    
    XCTAssertEqual(sut.progress(for: d, calendar: cal), 0.0, accuracy: 0.0001)
  }
  
  /// 저장된 값이 1 초과일 경우, 최대값 1로 클램핑되는지 검증합니다.
  func test_progress_ClampsGreaterThanOneToOne() {
    let d = day(2025, 8, 18)
    let sut: DayCompletionMap = [d: 3.14]
    
    XCTAssertEqual(sut.progress(for: d, calendar: cal), 1.0, accuracy: 0.0001)
  }
  
  /// 해당 날짜에 매핑된 값이 없을 경우, 기본값 0을 반환하는지 검증합니다.
  func test_progress_ReturnsZeroWhenNoEntry() {
    let sut: DayCompletionMap = [:]
    
    let p = sut.progress(for: day(2025, 8, 18), calendar: cal)
    
    XCTAssertEqual(p, 0.0, accuracy: 0.0001)
  }
}
