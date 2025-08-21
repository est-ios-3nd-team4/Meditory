//
//  UnifiedShadow.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

/// 통일된 Shadow UI를 위해 공통 Modifier를 만들었습니다.
///
/// .modifier(UnifiedShadow()) 위와 같이 modifier()로 묶어 사용할 수 있습니다.
///
/// Example :
/// ```
/// Rectangle()
///  .fill(Color.customContainer)
///  .frame(height: 140)
///  .clipShape(RoundedRectangle(cornerRadius: 20))
///  .modifier(UnifiedShadow())
///  .padding(20)
/// ```
/// 추가적인 사용 예시는 DailyNutritionView.swift에서 확인할 수 있습니다.
///
struct UnifiedShadow: ViewModifier {
  var enabled: Bool = true   // 그림자

  func body(content: Content) -> some View {
    if enabled {
      content
        .shadow(
          color: .customShadow,
          radius: 10,
          x: 0,
          y: 4
        )
    } else {
      content
    }
  }
}
