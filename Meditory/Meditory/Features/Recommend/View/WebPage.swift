import SwiftUI

struct WebPage: View {
  let url: URL
  let title: String

  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme

    var body: some View {
      WebView(url: url)
        .navigationBar(.custom(title))
    }
}

//#Preview {
//    WebPage()
//}
