import SwiftUI
import SwiftData


struct SettingView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  
  @Environment(\.userStore) private var userStore
  
  @State private var viewModel: SettingViewModel
  
  init() {
      // 앱의 실제 Store 싱글턴을 주입합니다.
      _viewModel = State(initialValue: SettingViewModel(settingStore: SettingStore.shared))
  }
  
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
                Text(currentUser?.name ?? "사용자 미등록")
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
              Task {
                await viewModel.updateNotificationSetting(newValue)
              }
            }
        }
        
        settingItem {
          Text("고객센터 문의하기")
            .font(.notoSans(size: 18))
        }
      }
      .padding()
      
    }
    .onAppear {
      Task {
        await viewModel.loadSetting()
      }
      
      printUsers()
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
  
  
  // 유저 정보 확인용 함수
  func printUsers() -> Void {
    if users.isEmpty {
      print("🤷‍♂️ User가 없습니다.")
      return
    }
    
    print("---------- 사용자 정보 조회 시작 ----------")
    for (index, user) in users.enumerated() {
      print("\n--- [ \(index)번 index 사용자 ] ---")
      print("🆔 ID: \(user.id)")
      print("👤 이름: \(user.name)")
      print("🏷️ 표시 이름: \(user.displayName)")
      print("🎂 생년월일: \(user.birthDate.formatted(date: .long, time: .omitted))")
      print("🚻 성별: \(user.gender)")
      
      // 1. 최신 사용자 프로필 (키/체중)
      if let profile = user.currentProfile {
        let height = profile.height != nil ? "\(profile.height!)cm" : "미입력"
        let weight = profile.weight != nil ? "\(profile.weight!)kg" : "미입력"
        print("📏 프로필 (키/체중): \(height) / \(weight)")
      } else {
        print("📏 프로필: 정보 없음")
      }
      
      // 2. 사용자 상태 (임신중 등)
      if !user.userStatuses.isEmpty {
        print("✨ 건강 상태:")
        for status in user.userStatuses {
          print("  - \(status.statusType)")
        }
      }
      
      // 3. 추가 정보 (알러지, 질병, 관심사)
      if let extraInfo = user.userExtraInfos.first {
        if !extraInfo.allergy.isEmpty {
          print("🤧 알레르기: \(extraInfo.allergy.map { $0.value }.joined(separator: ", "))")
        }
        if !extraInfo.disease.isEmpty {
          print("🩺 질병: \(extraInfo.disease.map { $0.value }.joined(separator: ", "))")
        }
        if !extraInfo.concern.isEmpty {
          print("❤️ 건강 관심사: \(extraInfo.concern.map { $0.value }.joined(separator: ", "))")
        }
      }
      
      // 4. 생활 습관
      if let lifeStyle = user.userLifeStyle {
        print("🌙 생활 습관: 기상 \(lifeStyle.wakeTime), 취침 \(lifeStyle.sleepTime)")
      }
    }
    print("\n---------- 사용자 정보 조회 종료 ----------")
  }
}


#Preview {
  SettingView()
    .modelContainer(DataController.shared.container)
    .environment(\.userStore, UserStore.shared)
}
