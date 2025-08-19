//
//  CalendarBackgroundViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/19/25.
//

import Foundation
import SwiftUI

@MainActor
final class CalendarBackgroundViewModel: ObservableObject {
  // 시트/헤더 상태
  @Published var isMonthSheetPresented: Bool = false
  @Published var isOverlappingHeader: Bool = false

  // 레이아웃 측정값
  @Published var headerBottomY: CGFloat = 0
  @Published var firstCardTopY: CGFloat = .infinity

  /// 헤더와 첫 카드의 상대 위치를 바탕으로 겹침 여부 갱신
  func updateOverlap() {
    isOverlappingHeader = firstCardTopY < (headerBottomY - 2)
  }

  /// 헤더 하단 Y가 변할 때 호출
  func onHeaderBottomYChanged(_ newY: CGFloat) {
    headerBottomY = newY
    updateOverlap()
  }

  /// 첫 카드 top Y가 변할 때 호출
  func onFirstCardTopChanged(_ newY: CGFloat) {
    firstCardTopY = newY
    updateOverlap()
  }
}
