//
//  CardStyle.swift
//  Meditory
//
//  Created by 홍승아 on 8/13/25.
//

import SwiftUI

/// 카드 형태 UI 스타일을 적용하는 ViewModifier
///
/// - 배경색은 다크 모드 여부에 따라 달라집니다.
///   - 다크 모드: 흰색(`Color.white`)의 30% 투명도
///   - 라이트 모드: 불투명 흰색(`Color.white`)
/// - 내부에 패딩을 적용하고, 모서리를 둥글게 처리합니다.
/// - 그림자는 `UnifiedShadow`를 통해 통일된 스타일을 적용합니다.
///
/// 사용 예시:
/// ```swift
/// Text("Hello Card")
///   .modifier(CardStyle(padding: 16, cornerRadius: 20))
/// ```
///
/// 또는 `View+Extension`의 `cardStyle()` 헬퍼 메서드를 통해 더 간단히 적용할 수 있습니다.
struct CardStyle: ViewModifier {
  @Environment(\.colorScheme) private var colorScheme
  /// 콘텐츠 내부 패딩
  var padding: CGFloat = .zero
  /// 모서리 둥글기
  var cornerRadius: CGFloat = 20

  func body(content: Content) -> some View {
    content
      .padding(padding)
      .background(
        colorScheme == .dark
        ? Color.white.opacity(0.3)
        : Color.white
      )
      .cornerRadius(cornerRadius)
      .modifier(UnifiedShadow())
  }
}
