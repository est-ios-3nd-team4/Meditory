//
//  CalendarBackgroundViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/19/25.
//

import Foundation
import SwiftUI

/// `CalendarBackgroundView`에서 사용하는 **상태 관리 뷰모델**입니다.
/// - 역할:
///   - 월 선택 시트(`isMonthSheetPresented`)의 표시 여부 관리
///   - 상단 주간 헤더와 첫 번째 카드 간의 위치 관계를 계산하여 겹침 상태(`isOverlappingHeader`)를 판별
///   - `GeometryReader`로 측정된 Y 좌표(`headerBottomY`, `firstCardTopY`)를 기반으로 UI 반응 제어
@MainActor
final class CalendarBackgroundViewModel: ObservableObject {
  // MARK: - UI 상태
  
  /// 월 선택 시트 표시 여부
  @Published var isMonthSheetPresented: Bool = false
  /// 상단 헤더와 카드가 겹치는 상태 여부
  @Published var isOverlappingHeader: Bool = false
  
  // MARK: - 레이아웃 측정값
  
  /// 상단 헤더의 하단 Y 좌표
  @Published var headerBottomY: CGFloat = 0
  /// 첫 번째 카드의 상단 Y 좌표
  @Published var firstCardTopY: CGFloat = .infinity
  
  // MARK: - Public Methods
  
  /// 헤더와 첫 번째 카드의 상대 위치를 기반으로 **겹침 여부**를 갱신합니다.
  func updateOverlap() {
    // 약간의 오차 보정을 위해 -2 적용
    isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
  }
  
  /// 헤더 하단 Y 값이 변경되었을 때 호출됩니다.
  /// - Parameter newY: 새로 측정된 헤더 하단 Y 좌표
  func onHeaderBottomYChanged(_ newY: CGFloat) {
    headerBottomY = newY
    updateOverlap()
  }
  
  /// 첫 번째 카드의 top Y 값이 변경되었을 때 호출됩니다.
  /// - Parameter newY: 새로 측정된 카드 상단 Y 좌표
  func onFirstCardTopChanged(_ newY: CGFloat) {
    firstCardTopY = newY
    updateOverlap()
  }
}
