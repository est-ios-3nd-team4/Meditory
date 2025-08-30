import Foundation
import SwiftUI
import SwiftData
import UserNotifications

// 최신 Swift Concurrency를 위해 @Observable 매크로를 사용
@Observable
class SettingViewModel {
  // UI와 바인딩될 프로퍼티는 그대로 유지
  var isNotificationOn: Bool = false

  // 시스템 설정 권한 상태
  var isSystemGranted: Bool = false
  
  // Store를 외부에서 주입받도록 함. 이제 ViewModel은 어떤 Store를 사용할지 스스로 결정하지 않으며, 테스트가 용이
  private let settingStore: SettingStore
  
  // 생성자를 통해 Store 인스턴스를 주입
  init(settingStore: SettingStore) {
    self.settingStore = settingStore
  }
  
  // 모든 메서드는 비동기로 선언되고, MainActor에서 실행됨
  @MainActor
  func loadSetting() async {
    // Store의 비동기 메서드를 await로 호출
    if let existingSetting = await settingStore.fetchSetting() {
      // 가져온 데이터로 UI 상태(@Published 프로퍼티)를 업데이트
      self.isNotificationOn = existingSetting.isNotificationOn
    } else {
      // 설정이 없는 경우, 기본값(false)으로 생성하고 UI 상태를 업데이트
      // updateNotificationSetting은 내부적으로 생성(create) 로직을 포함
      await settingStore.updateNotificationSetting(false)
      self.isNotificationOn = false
    }
    await refreshSystemAuth()
    // 권한이 없는데 토글이 ON이면 강제 OFF로 정합성 유지
    if isNotificationOn && !isSystemGranted {
      self.isNotificationOn = false
      await settingStore.updateNotificationSetting(false)
    }
  }

  // 시스템 권한 스냅샷 갱신
  @MainActor
  func refreshSystemAuth() async {
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    self.isSystemGranted = (status == .authorized || status == .provisional || status == .ephemeral)
  }

  /// 권한/토글 상태에 맞춰 스케줄 동기화
  @MainActor
  func refreshAndSync() async {
    await refreshSystemAuth()
    // 앱 토글과 시스템 권한이 모두 true일 때만 스케줄 생성
    if isSystemGranted && isNotificationOn {
      let ctx = DataController.shared.container.mainContext
      await RoutineNotificationScheduler().scheduleAll()
    } else {
      NotificationManager.shared.cancelAllIncludingDelivered()
    }
  }

  @MainActor
  func updateNotificationSetting(_ value: Bool) async {
    // 1. UI 상태를 즉시 업데이트
    self.isNotificationOn = value

    // 2. Store를 통해 백그라운드에서 데이터베이스에 비동기적으로 저장
    await settingStore.updateNotificationSetting(value)

    // 3. 시스템 권한 요청/확인
    let result = await NotificationManager.shared.setNotificationsEnabled(value)

    if value, result == .enabled {
      let context = DataController.shared.container.mainContext
      await RoutineNotificationScheduler().scheduleAll()
    } else if value, result == .denied {
      // 권한 거부 → 앱 토글 롤백
      self.isNotificationOn = false
      await settingStore.updateNotificationSetting(false)
      NotificationManager.shared.cancelAllIncludingDelivered()
    } else if !value {
      // 앱 토글 OFF → 모두 취소
      NotificationManager.shared.cancelAllIncludingDelivered()
    }

    // 4. 최종 권한 상태 반영
    await refreshSystemAuth()
  }
}
