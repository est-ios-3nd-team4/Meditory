//
//  ScrollTopObserver.swift
//  Meditory
//
//  Created by 홍승아 on 8/24/25.
//

import SwiftUI

/// 스크롤 뷰의 최상단 여부를 관찰하는 뷰
/// - `ScrollOffsetKey`를 사용해 스크롤 위치(`minY`)를 추적
/// - 상위 뷰에서 바인딩된 `isAtTop` 값을 자동 갱신
struct ScrollTopObserver: View {
  
  /// 스크롤이 최상단(또는 일정 오차 범위 내)일 경우 true
  @Binding var isAtTop: Bool
  
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .frame(height: .zero)
        .preference(
          key: ScrollOffsetKey.self,
          value: geometry.frame(in: CoordinateSpaceName.scroll.coordinateSpace).minY
        )
        .onPreferenceChange(ScrollOffsetKey.self) { value in
          // 스크롤이 거의 최상단(허용 오차: defaultSpacing)인지 확인
          let newIsAtTop = round(value) >= -.defaultSpacing
          
          if newIsAtTop != isAtTop {
            isAtTop = round(value) >= -.smallSpacing
          }
        }
    }
  }
}
