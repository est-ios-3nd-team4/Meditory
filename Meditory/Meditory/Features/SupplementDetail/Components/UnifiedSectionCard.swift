import SwiftUI

/// 앱 전반에서 통일된 카드 레이아웃
struct UnifiedSectionCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      content
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(colorScheme == .dark ? Color.white.opacity(0.08) : .white)
    .cornerRadius(.defaultRadius)
    .modifier(UnifiedShadow())
  }
}
