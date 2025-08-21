import SwiftUI

struct WebPage: View {
  let url: URL
  let title: String

  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

    var body: some View {
      WebView(url: url)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              dismiss()
            } label: {
              Image(systemName: "chevron.left")
            }
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }
        }
    }
}

//#Preview {
//    WebPage()
//}
