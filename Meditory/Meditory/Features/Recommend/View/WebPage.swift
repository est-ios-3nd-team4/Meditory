import SwiftUI

struct WebPage: View {
  let url: URL
  let title: String
  
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    WebView(url: url)
      .navigationBarBackButtonHidden(true)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "chevron.left")
              .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .gray)
          }
        }
        
        ToolbarItem(placement: .principal) {
          Text(title)
            .lineLimit(1)
            .truncationMode(.tail)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Color.clear.frame(width: 44, height: 44)
        }
      }
  }
}
