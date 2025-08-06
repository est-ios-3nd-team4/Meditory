import SwiftUI

struct SettingsView: View {
    @State private var receiveNotifications = true
    @State private var pillNotification = true
    @State private var hospitalNotification = true
    @State private var healthKitSync = true
    @State private var calendarSync = true
    @State private var hospitalRecordConsent = true
    
    var body: some View {
        NavigationView {
            List {
                // 프로필 섹션
                Section {
                    HStack(alignment: .center, spacing: 16) {
                        // 프로필 이미지 (placeholder)
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 56, height: 56)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("이름")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("홍길동")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
                
                // 추가 정보 섹션
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("사진")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("성별, 출생 연도, 키 등")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                
                // 알림 수신 설정 토글
                Section {
                    Toggle("알림 수신 설정", isOn: $receiveNotifications)
                }
                
                // 알림 세부 설정
                Section(header: Text("알림 수신 설정")) {
                    Toggle("약 알람", isOn: $pillNotification)
                    Toggle("병원 예약 알람", isOn: $hospitalNotification)
                }
                
                // 연동 설정
                Section(header: Text("연동 설정")) {
                    Toggle("HealthKit 연동", isOn: $healthKitSync)
                    Toggle("캘린더 연동", isOn: $calendarSync)
                    Toggle("병원 방문 기록 수집 동의", isOn: $hospitalRecordConsent)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("설정")
        }
    }
}

#Preview {
    SettingsView()
}
