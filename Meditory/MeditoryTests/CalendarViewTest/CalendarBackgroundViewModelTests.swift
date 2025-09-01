//
//  CalendarBackgroundViewModelTests.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//


import XCTest
@testable import Meditory
import SwiftUI

/// `CalendarBackgroundViewModel`의 헤더-콘텐츠 겹침 판정 로직을 검증하는 단위 테스트입니다.
/// - 주요 검증 항목:
///   - `firstCardTopY < headerBottomY - 2`일 때 `isOverlappingHeader == true`
///   - 경계값/초과값에서 `isOverlappingHeader == false`
///   - `onHeaderBottomYChanged(_:)` 호출 시 즉시 재평가 동작
final class CalendarBackgroundViewModelTests: XCTestCase {
  
  /// `firstCardTopY`가 `headerBottomY - 2`보다 작은 경우
  /// 헤더와 겹친 것으로 판정(`isOverlappingHeader = true`)되는지 검증합니다.
  ///
  /// - Given: `headerBottomY = 200`, `firstCardTopY = 197`
  /// - Then: `197 < 198(=200-2)` 이므로 `isOverlappingHeader`가 `true`가 되어야 합니다.
  @MainActor
  func test_updateOverlap_SetsTrue_WhenFirstCardTopIsAboveHeaderBottomMinus2() {
    let sut = CalendarBackgroundViewModel()
    sut.onHeaderBottomYChanged(200)  // header bottom
    sut.onFirstCardTopChanged(197)   // 197 < 198(=200-2) → true
    XCTAssertTrue(sut.isOverlappingHeader)
  }
  
  /// `firstCardTopY`가 `headerBottomY - 2`와 같거나 큰 경우
  /// 겹치지 않은 것으로 판정(`isOverlappingHeader = false`)되는지 검증합니다.
  ///
  /// - Given: `headerBottomY = 200`
  /// - When:
  ///   - `firstCardTopY = 198` (경계값: `198 == 200-2`)
  ///   - `firstCardTopY = 250` (명백한 비겹침)
  /// - Then: 모두 `isOverlappingHeader == false` 여야 합니다.
  @MainActor
  func test_updateOverlap_SetsFalse_WhenFirstCardTopIsBelowOrEqualThreshold() {
    let sut = CalendarBackgroundViewModel()
    sut.onHeaderBottomYChanged(200)
    
    sut.onFirstCardTopChanged(198) // 경계값: 198 == 200-2 → false
    XCTAssertFalse(sut.isOverlappingHeader)
    
    sut.onFirstCardTopChanged(250) // 여유 충분 → false
    XCTAssertFalse(sut.isOverlappingHeader)
  }
  
  /// `onHeaderBottomYChanged(_:)` 호출 시 내부적으로 `updateOverlap()`이 즉시 실행되어
  /// `isOverlappingHeader` 상태가 올바르게 갱신되는지 검증합니다.
  ///
  /// - Given: `firstCardTopY`가 미리 설정된 상태
  /// - When: `headerBottomY`를 변경
  /// - Then: 변경 직후의 임계 비교 결과에 따라 `isOverlappingHeader`가 반영되어야 합니다.
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
