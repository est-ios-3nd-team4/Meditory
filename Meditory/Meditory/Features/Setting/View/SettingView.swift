import SwiftUI
import SwiftData


struct SettingView: View {
  @Environment(\.modelContext) private var context
  @StateObject private var viewModel = SettingViewModel()

  // DB의 User 목록 자동 바인딩
  @Query private var users: [User]
  private let userStore = UserStore()
  

  var body: some View {
    List {
      // 현재(첫 번째) 유저
      let currentUser = users.first

      NavigationLink(destination: SettingSubView()) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(/*currentUser?.displayName*/currentUser?.name ?? "사용자 미등록")
              .font(.title3)
              .foregroundColor(.primary)
            Text("내 정보 ∙ 건강 정보 관리")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
        }
      }

      Toggle("알림 수신 설정", isOn: $viewModel.isNotificationOn)
        .tint(.accent)
        .onChange(of: viewModel.isNotificationOn) { oldValue, newValue in
          viewModel.updateNotificationSetting(newValue, context: context)
        }

      Text("고객센터 문의하기")


      // 임시섹션. 추후삭제할 예정
      Section("사용자 관리") {
        Button("샘플 유저 생성") {
          createSampleUser()
        }
        Button(role: .destructive) {
          deleteAllUsers()
        } label: {
          Text("모든 유저 삭제")
        }
      }

    }
    .task {
      viewModel.loadSetting(context: context)
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
    userStore.addUser(sample, context: context)
    userStore.loadUser(context: context)
  }
  // 모든 유저 삭제
  private func deleteAllUsers() {
    userStore.deleteAllUsers(context: context)
    userStore.currentUser = nil
  }



}



#Preview {
  let container = try! ModelContainer(for: Setting.self, User.self)
  return SettingView()
      .modelContainer(container)
}
