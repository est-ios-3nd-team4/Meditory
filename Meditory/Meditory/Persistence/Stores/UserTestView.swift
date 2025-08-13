// MARK: --
// SwiftData Manager(Store) 의 사용법을 시험하기 위한 테스트 페이지


import SwiftUI
import SwiftData

struct UserTestView: View {
  // MARK: - SwiftData 를 뷰에서 쓰기 위한 준비
  @Environment(\.modelContext) var context
  // 여러가지 store 중 써야 하는 store 를 생성
  let userStore = UserStore()

  @State private var users: [User] = []
  @State private var name: String = ""
  @State private var gender: String = ""
  @State private var displayName: String = ""
  @State private var height: String = ""
  @State private var weight: String = ""

  var body: some View {
    ScrollView{
      VStack(spacing: 20) {
        Group {
          TextField("이름", text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          TextField("성별", text: $gender)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          TextField("표시이름", text: $displayName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          Button("🟢 유저 추가하기") {
            let newUser = User(
              name: name,
              birthDate: Date(),
              gender: gender,
              displayName: displayName
            )
            userStore.addUser(newUser, context: context)
            refreshUsers()
          }
        }
        Divider()
        Group {
          TextField("키 (cm)", text: $height)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          TextField("몸무게 (kg)", text: $weight)
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())

          // MARK: - User의 하위테이블 생성하는 법
          Button("🟣 프로필 추가하기") {
            if let h = Double(height), let w = Double(weight) {
              let profile = UserProfile(height: h, weight: w, createdAt: .now, user: userStore.currentUser)
              userStore.addUserProfile(profile, context: context)
              height = ""
              weight = ""
            }
          }
        }
        Divider()
        Button("❌ 모든 유저 삭제") {
          userStore.deleteAllUsers(context: context)
          refreshUsers()
        }
        Divider()
        Button("❌ 모든 프로필 삭제") {
          userStore.deleteAllProfiles(context: context)
          refreshUsers()
        }
        Divider()


        Button("📥 유저 불러오기") {
          refreshUsers()
        }
        ForEach(users, id: \.id) { user in
          VStack(alignment: .leading) {
            Text("id: \(user.id)")
            Text("이름: \(user.name)")
            Text("성별: \(user.gender)")
            Text("표시이름: \(user.displayName)")
            ForEach(user.userProfiles, id: \.id) { profile in
              VStack(alignment: .leading, spacing: 4) {
                Text("📄 프로필")
                Text(" - 연결 user: \(profile.user?.name)")
                Text(" - 키: \(profile.height) cm")
                Text(" - 몸무게: \(profile.weight) kg")
                Text(" - 생성일: \(profile.createdAt.formatted())")
              }
              .padding(.leading, 10)
              .font(.subheadline)
            }
          }
        }
      }
      .padding()
      .onAppear {
        refreshUsers()

      }
    }
  }

  func refreshUsers() {
    let newUsers = userStore.fetchUsers(context: context)
    users = newUsers // ✅ 새로 할당
    userStore.loadUser(context: context)
  }
}
