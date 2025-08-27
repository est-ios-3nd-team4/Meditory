import SwiftUI

struct SettingSubView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  
  // OnboardingView에 전달하기 위해 userStore를 가져옵니다.
  @Environment(\.userStore) private var userStore
  
  // 부모 뷰로부터 초기화 동작을 전달받습니다.
  // let onReset: () -> Void // TODO: 초기화 기능 구현 시 이 부분을 활성화해야 합니다.
  
  var body: some View {
    ZStack {
      Color.customBackground.ignoresSafeArea()
      
      VStack(alignment: .leading, spacing: 16) {
        // MARK: - OnboardingView를 수정 모드로 호출
        NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .base, isEditing: true)) {
          settingSubItem {
            Text("기본 정보")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
        
        NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .gender, isEditing: true)) {
          settingSubItem {
            Text("성별")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
        
        NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .allergy, isEditing: true)) {
          settingSubItem {
            Text("알레르기")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
        
        NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .disease, isEditing: true)) {
          settingSubItem {
            Text("질병")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
        
        NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .concern, isEditing: true)) {
          settingSubItem {
            Text("건강 관심사")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
        
        // '초기화'는 화면 이동이 아닌 동작이므로 Button으로 구현하는 것이 좋습니다.
        Button(action: {
          // TODO: 여기에 사용자 정보 초기화 로직을 구현해야 합니다.
          // 예: userStore.deleteAllUsers() 등
          print("초기화 버튼 탭됨")
        }) {
          settingSubItem {
            Text("초기화")
              .font(.notoSans(size: 18))
              .foregroundColor(.primary)
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    .navigationBar(.custom("내 정보 ∙ 건강 정보 관리")) {
      dismiss()
    }
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
  NavigationStack {
    // TODO: 초기화 기능 구현 시 onReset 파라미터를 전달해야 합니다.
    SettingSubView(/*onReset: {}*/)
      .environment(\.userStore, UserStore.shared)
  }
}
