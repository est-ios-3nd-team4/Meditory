import SwiftUI
import SwiftData


struct SettingView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  
  @Environment(\.userStore) private var userStore
  
  @StateObject private var viewModel = SettingViewModel()
  
  // DB의 User 목록 자동 바인딩
  @Query private var users: [User]
  
  
  var body: some View {
    
    ZStack(alignment: .top) {
      (colorScheme == .dark ? Color.black : Color.customBackground)
        .ignoresSafeArea(edges: .top)
      
      VStack(spacing: .defaultSpacing) {
        let currentUser = users.first
        
        NavigationLink(destination: SettingSubView()) {
          settingItem {
            HStack {
              VStack(alignment: .leading, spacing: 16) {
                Text(currentUser?.displayName ?? "사용자 미등록")
                  .font(.notoSans(size: 18))
                  .foregroundColor(.primary)
                
                Text("내 정보 ∙ 건강 정보 관리")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              
              Spacer()
              
              Image(systemName: "chevron.right")
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
            }
          }
        }
        
        settingItem {
          Toggle("알림 수신 설정", isOn: $viewModel.isNotificationOn)
            .font(.notoSans(size: 18))
            .tint(.accent)
            .onChange(of: viewModel.isNotificationOn) { oldValue, newValue in
              viewModel.updateNotificationSetting(newValue, context: context)
            }
        }
        
        settingItem {
          Text("고객센터 문의하기")
            .font(.notoSans(size: 18))
        }
        
        
        // 임시 버튼들 (테스트용)
        VStack {
          Button("샘플 유저 생성") {
            createSampleUser()
          }
          .buttonStyle(.borderedProminent)
          
          Button("모든 유저 삭제") {
            deleteAllUsers()
          }
          .buttonStyle(.bordered)
        }
        
      }
      .padding()
      
      
    }
  }
  
  
  
  // 임시 함수라 나중에 삭제할 예정임
  // 샘플 유저 생성
  private func createSampleUser() {
    let sample = User(
      name: "챝짚티",
      birthDate: Date(),
      gender: "M",
      displayName: "샘플유저맨"
    )
    Task {
      await userStore.addUser(sample)
    }
  }
  
  // 모든 유저 삭제
  private func deleteAllUsers() {
    Task {
      await userStore.deleteAllUsers()
    }
  }
  
  
  
  // 둥근네모 만드는 함수
  @ViewBuilder
  func settingItem<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.vertical, 20)   //  내부 상하여백
      .padding(.horizontal, 16) //  내부 좌우여백
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.white.opacity(0.8))
      )
      .modifier(UnifiedShadow())
  }
}


#Preview {
  SettingView()
    .modelContainer(DataController.shared.container)
    .environment(\.userStore, UserStore.shared)
}
