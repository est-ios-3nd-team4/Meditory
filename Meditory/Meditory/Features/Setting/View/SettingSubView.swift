import SwiftUI

struct SettingSubView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("기본 정보")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
      
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("성별")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
      
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("알레르기")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
      
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("질병")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
      
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("건강 관심사")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
      
      NavigationLink(destination: Color.red) {
        settingSubItem {
          Text("초기화")
            .font(.notoSans(size: 18))
            .foregroundColor(.primary)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .navigationBar(.none)
  }
  
  
  
  // 커스텀 리스트 만드는 함수
  @ViewBuilder
  func settingSubItem<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    HStack {
      content()
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 0)   //  내부 상하여백
    .padding(.horizontal, 32) //  내부 좌우여백
    .background(
      Rectangle()
        .fill(Color.clear)
    )
    .modifier(UnifiedShadow())
  }
}

#Preview {
  SettingSubView()
}
