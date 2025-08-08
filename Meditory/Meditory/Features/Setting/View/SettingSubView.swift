import SwiftUI

struct SettingSubView: View {
  var body: some View {
//    NavigationView {
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
//    }
  }
}

#Preview {
  SettingSubView()
}
