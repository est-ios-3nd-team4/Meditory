import SwiftUI

struct SettingSubView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    List {
      NavigationLink(destination: Color.red) {
        Text("이름")
          .font(.title3)
          .foregroundColor(.primary)
      }

      NavigationLink(destination: Color.red) {
        Text("출생년도")
          .font(.title3)
          .foregroundColor(.primary)
      }

      NavigationLink(destination: Color.red) {
        Text("키 및 체중")
          .font(.title3)
          .foregroundColor(.primary)
      }

      NavigationLink(destination: Color.red) {
        Text("건강 상태 조사")
          .font(.title3)
          .foregroundColor(.primary)
      }

      NavigationLink(destination: Color.red) {
        Text("초기화")
          .font(.title3)
          .foregroundColor(.primary)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
        }
      }
    }
  }
}

#Preview {
  SettingSubView()
}
