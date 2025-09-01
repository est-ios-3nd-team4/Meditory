import SwiftUI

/// 내장 WebView를 표시하는 화면.
/// 네비게이션 바에 뒤로가기 버튼, 제목을 커스텀하여 보여준다.
struct WebPage: View {
  /// 표시할 웹 페이지 URL
  let url: URL
  /// 네비게이션 바에 표시할 제목
  let title: String
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    WebView(url: url)
      .navigationBarBackButtonHidden(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        // 좌측: 뒤로가기 버튼
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
          }
        }

        // 중앙: 페이지 제목
        ToolbarItem(placement: .principal) {
          Text(title)
            .lineLimit(1)
            .truncationMode(.tail)
        }

        // 우측: 빈 공간 확보용 (정렬 균형)
        ToolbarItem(placement: .navigationBarTrailing) {
          Color.clear.frame(width: 44, height: 44)
        }
      }
  }
}
