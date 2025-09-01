import SwiftUI
import SwiftData


struct SettingView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.modelContext) private var context
  
  @Environment(\.userStore) private var userStore
  @Environment(\.scenePhase) private var scenePhase
  @State private var viewModel: SettingViewModel
  
  init() {
      // 앱의 실제 Store 싱글턴을 주입함
      _viewModel = State(initialValue: SettingViewModel(settingStore: SettingStore.shared))
  }
  
  // DB의 User 목록 자동 바인딩
  @Query private var users: [User]
  
  
  var body: some View {
    // users 배열에서 첫 번째 사용자를 가져옴
    let currentUser = users.first
    
    ZStack(alignment: .top) {
      (colorScheme == .dark ? Color.black : Color.customBackground)
        .ignoresSafeArea(edges: .top)
      
      VStack(spacing: .defaultSpacing) {
        Text(currentUser?.name ?? "설정")
          .font(.largeTitle)
          .fontWeight(.bold) // 폰트 두께를 bold로 설정함
          .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 정렬
          .padding(.bottom, 10) // 아래쪽에 약간의 여백을 줌
        
        NavigationLink(destination: SettingSubView()) {
          settingItem {
            Text("내 정보 ∙ 건강 정보 관리")
              .font(.notoSans(size: .defaultFontSize))
              .foregroundStyle(.primary)
          }
        }
        .buttonStyle(.plain) // NavigationLink의 기본 스타일(파란색)을 제거함
        
        settingItem {
          Button {
            NotificationManager.shared.openSystemSettings()
          } label: {
            HStack {
              Text("알림")
                .font(.notoSans(size: .defaultFontSize))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading) // 레이아웃을 전체 너비로 확장함
                .contentShape(Rectangle()) // 터치 영역을 사각형 프레임 전체로 확장함
              
              Text(viewModel.isSystemGranted ? "ON" : "OFF")
                .font(.notoSans(size: .defaultFontSize - 4))
                .foregroundColor(.secondary)
                .padding(.trailing, 4)
            }
          }
          .buttonStyle(.plain) // 기본 버튼 스타일 제거 → 기존 settingItem 스타일 유지
        }
        
        settingItem {
          // "mailto:" 링크를 사용하여 탭하면 이메일 앱을 열도록 수정함
          if let url = URL(string: "mailto:drfranken99@gmail.com") {
            Link(destination: url) {
              HStack {
                Text("고객센터 문의하기")
                  .font(.notoSans(size: .defaultFontSize))
                  .foregroundStyle(.primary) // 링크의 기본 파란색 스타일을 덮어쓰기 위함
                  .frame(maxWidth: .infinity, alignment: .leading) // 레이아웃을 전체 너비로 확장함
                  .contentShape(Rectangle()) // 터치 영역을 사각형 프레임 전체로 확장함
              }
            }
          }
        }
        .buttonStyle(.plain)
      }
      .padding()
      
    }
    .onAppear {
      Task {
        await viewModel.loadSetting()
      }
      
      printUsers()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        Task { await viewModel.refreshAndSync() }
      }
    }
  }
  
  
  // 둥근네모 만드는 함수
  @ViewBuilder
  func settingItem<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    content()
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: 26) // 토글버튼때문에 각 항목의 높이가 달라지는 것 때문에 추가
      .padding(.vertical, .defaultSpacing)   //  내부 상하여백
      .padding(.horizontal, .defaultSpacing) //  내부 좌우여백
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
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
  // NavigationView 또는 NavigationStack으로 감싸야 타이틀이 보임
  NavigationView {
    SettingView()
      .modelContainer(DataController.shared.container)
      .environment(\.userStore, UserStore.shared)
  }
}
