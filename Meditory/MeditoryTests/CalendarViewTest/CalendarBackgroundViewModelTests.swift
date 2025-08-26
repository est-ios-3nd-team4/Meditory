//
//  CalendarBackgroundViewModelTests.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//


import XCTest
@testable import Meditory
import SwiftUI

/// 겹침 판정 로직 테스트
final class CalendarBackgroundViewModelTests: XCTestCase {
  /// `firstCardTopY`가 `headerBottomY - 2`보다 작은 경우
  /// → 헤더와 겹친 것으로 판정(`isOverlappingHeader = true`)되는지 검증
  @MainActor
  func test_updateOverlap_SetsTrue_WhenFirstCardTopIsAboveHeaderBottomMinus2() {
    let sut = CalendarBackgroundViewModel()
    sut.onHeaderBottomYChanged(200)  // header bottom
    sut.onFirstCardTopChanged(197)   // 197 < 198(=200-2) → true
    XCTAssertTrue(sut.isOverlappingHeader)
  }

  /// `firstCardTopY`가 `headerBottomY - 2`와 같거나 큰 경우
  /// → 겹치지 않은 것으로 판정(`isOverlappingHeader = false`)되는지 검증
  @MainActor
  func test_updateOverlap_SetsFalse_WhenFirstCardTopIsBelowOrEqualThreshold() {
    let sut = CalendarBackgroundViewModel()
    sut.onHeaderBottomYChanged(200)

    sut.onFirstCardTopChanged(198) // 경계값: 198 == 200-2 → false
    XCTAssertFalse(sut.isOverlappingHeader)

    sut.onFirstCardTopChanged(250) // 여유 충분 → false
    XCTAssertFalse(sut.isOverlappingHeader)
  }

  /// `onHeaderBottomYChanged` 호출 시
  /// 내부적으로 `updateOverlap()`이 즉시 재평가되어
  /// `isOverlappingHeader` 상태가 올바르게 갱신되는지 검증
  @MainActor
  func test_onHeaderBottomYChanged_ReevaluatesOverlap() {
    let sut = CalendarBackgroundViewModel()
    sut.onFirstCardTopChanged(150)
    sut.onHeaderBottomYChanged(160) // 150 < 158 -> true
    XCTAssertTrue(sut.isOverlappingHeader)

    sut.onHeaderBottomYChanged(100) // 150 < 98 -> false
    XCTAssertFalse(sut.isOverlappingHeader)
  }
}
