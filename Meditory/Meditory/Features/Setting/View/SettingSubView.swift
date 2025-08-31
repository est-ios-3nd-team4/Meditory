import SwiftUI
import SwiftData

struct SettingSubView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss
  
  // OnboardingView에 전달하기 위해 userStore를 가져옴
  @Environment(\.userStore) private var userStore
  
  // DB에서 User 목록을 가져오기 위함
  @Query private var users: [User]
  
  var body: some View {
    // users 배열에서 첫 번째 사용자를 가져옴
    let currentUser = users.first
    
    ZStack {
      Color.customBackground.ignoresSafeArea()
      
      ScrollView {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
          // MARK: - 기본 정보
          NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .base, isEditing: true)) {
            settingSubItem(
              title: "기본 정보",
              // 사용자 이름, 출생 연도, 키/몸무게 정보를 표시함
              details: [
                currentUser?.name ?? "미입력",
                formatBirthYear(currentUser?.birthDate), // 출생 연도만 표시하도록 수정함
                formatProfile(currentUser?.currentProfile)
              ]
            )
          }
          
          // MARK: - 성별 및 상태
          NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .gender, isEditing: true)) {
            settingSubItem(
              title: "성별 및 상태",
              // 사용자 성별 및 건강 상태를 표시함
              details: [
                currentUser?.gender ?? "미입력",
                formatUserStatus(currentUser?.userStatuses)
              ]
            )
          }
          
          // MARK: - 알레르기
          NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .allergy, isEditing: true)) {
            let detailsText = {
              guard let allergies = currentUser?.userExtraInfos.first?.allergy, !allergies.isEmpty else {
                return "해당 없음"
              }
              return allergies.map { $0.value }.joined(separator: ", ")
            }()
            settingSubItem(
              title: "알레르기",
              details: [detailsText]
            )
          }
          
          // MARK: - 질병
          NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .disease, isEditing: true)) {
            let detailsText = {
              guard let diseases = currentUser?.userExtraInfos.first?.disease, !diseases.isEmpty else {
                return "해당 없음"
              }
              return diseases.map { $0.value }.joined(separator: ", ")
            }()
            settingSubItem(
              title: "질병",
              details: [detailsText]
            )
          }
          
          // MARK: - 건강 관심사
          NavigationLink(destination: OnboardingView(userStore: userStore, startAt: .concern, isEditing: true)) {
            let detailsText = {
              guard let concerns = currentUser?.userExtraInfos.first?.concern, !concerns.isEmpty else {
                return "해당 없음"
              }
              return concerns.map { $0.value }.joined(separator: ", ")
            }()
            settingSubItem(
              title: "건강 관심사",
              details: [detailsText]
            )
          }
        }
        .padding()
      }
    }
    .buttonStyle(.plain) // NavigationLink의 기본 스타일(파란색)을 제거함
    .navigationBar(.custom("내 정보 ∙ 건강 정보 관리")) {
      dismiss()
    }
  }
  
  // MARK: - Helper Functions
  
  /// 출생 연도 정보를 포맷하는 함수
  private func formatBirthYear(_ date: Date?) -> String {
      guard let date = date else { return "미입력" }
      let calendar = Calendar.current
      let year = calendar.component(.year, from: date)
      return "\(year)년"
  }
  
  /// 키와 몸무게 정보를 포맷하는 함수
  private func formatProfile(_ profile: UserProfile?) -> String {
    guard let profile = profile else { return "미입력" }
    let height = profile.height != nil ? "\(profile.height!)cm" : "키 미입력"
    let weight = profile.weight != nil ? "\(profile.weight!)kg" : "몸무게 미입력"
    return "\(height) / \(weight)"
  }
  
  /// 사용자 건강 상태 정보를 포맷하는 함수 ("동의" 항목 필터링)
  private func formatUserStatus(_ statuses: [UserStatus]?) -> String {
    guard let statuses = statuses, !statuses.isEmpty else { return "해당 없음" }
    
    // "동의" 텍스트가 포함되지 않은 상태만 필터링함
    let filteredStatuses = statuses.filter { !$0.statusType.contains("동의") }
    
    // 필터링 후 상태가 없으면 "해당 없음"을 반환함
    guard !filteredStatuses.isEmpty else { return "해당 없음" }
    
    // 필터링된 상태 목록을 문자열로 조합함
    return filteredStatuses.map { "\($0.statusType)" }.joined(separator: ", ")
  }
  
  // MARK: - View Builder
  
  /// 제목과 상세 정보가 포함된 둥근 사각형 UI를 만드는 함수
  @ViewBuilder
  func settingSubItem(title: String, details: [String]) -> some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      HStack {
        Text(title)
          // .font 파라미터 순서를 weight -> size로 수정함
          .font(.notoSans(size: .defaultFontSize))
          .foregroundStyle(.primary)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
      }
      
      // 상세 정보가 있는 경우에만 표시함
      if !details.allSatisfy({ $0.isEmpty || $0 == "미입력" || $0 == "해당 없음" }) {
        VStack(alignment: .leading, spacing: 4) {
          ForEach(details.filter { !$0.isEmpty }, id: \.self) { detail in
            Text(detail)
              .font(.notoSans(size: 15))
              .foregroundStyle(.secondary)
              .lineLimit(1) // 상세 정보는 한 줄로 표시함
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color.white.opacity(0.2) : Color.white)
    )
    .modifier(UnifiedShadow())
  }
}

#Preview {
  NavigationStack {
    SettingSubView()
      .modelContainer(DataController.shared.container)
      .environment(\.userStore, UserStore.shared)
  }
}
