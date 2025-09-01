//
//  UnifiedShadow.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import SwiftUI

/// UnifiedShadow
///
/// 앱 전반에서 일관된 그림자 효과(Shadow)를 적용하기 위해 만든 **공통 ViewModifier** 입니다.
/// 개별 뷰마다 다른 그림자를 설정하는 대신, 이 Modifier를 적용하면 디자인 시스템에 맞춘
/// 동일한 그림자 스타일을 유지할 수 있습니다.
///
/// - 주요 특징:
///   - **enabled**: `true`일 경우 그림자 적용, `false`일 경우 그림자 미적용.
///   - 그림자 속성은 프로젝트에서 정의한 `Color.customShadow` 와 `.smallRadius`를 사용하여 통일된 스타일 유지.
///   - y축 방향으로 약간의 오프셋을 주어 자연스러운 부양감(입체감) 제공.
///
/// - 사용 방법:
///   - `.modifier(UnifiedShadow())` 형태로 적용.
///   - 다른 Modifier와 함께 사용 가능하며, Card·Container·Button 등 다양한 컴포넌트에 재사용 가능.
///
/// - 적용 사례:
///   - 카드형 뷰(`UnifiedSectionCard`, `DailyNutritionView` 등)에 기본적으로 사용.
///   - 디자인 일관성 유지 및 코드 중복 제거 목적.
///
/// - Parameters:
///   - `enabled`: Bool (기본값 `true`) → 필요 시 그림자 효과를 끄고 싶을 때 `false`로 지정.
///
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
struct UnifiedShadow: ViewModifier {
  var enabled: Bool = true   // 그림자

  func body(content: Content) -> some View {
    if enabled {
      content
        .shadow(
          color: .customShadow,
          radius: .smallRadius,
          x: 0,
          y: 4
        )
    } else {
      content
    }
  }
}
