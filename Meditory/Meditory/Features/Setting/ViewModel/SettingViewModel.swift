import Foundation
import SwiftUI
import SwiftData
import UserNotifications

// SwiftUI 최신 Concurrency 대응을 위해 @Observable 매크로를 사용함
@Observable
class SettingViewModel {
  // MARK: - Properties
  
  /// 앱 내 알림 설정 토글 상태를 나타냄 (UI 바인딩)
  var isNotificationOn: Bool = false
  
  /// 시스템의 알림 권한 부여 상태를 나타냄
  var isSystemGranted: Bool = false
  
  // 의존성 주입: 데이터 처리를 담당하는 Store임
  private let settingStore: SettingStore
  
  // MARK: - Initializer
  
  /// SettingViewModel을 초기화함.
  /// - Parameter settingStore: 앱의 설정 데이터를 관리하는 `SettingStore` 구현체임.
  init(settingStore: SettingStore) {
    self.settingStore = settingStore
  }
  
  // MARK: - Public Methods
  
  /// 저장된 설정 값을 불러와 ViewModel의 상태를 초기화함.
  ///
  /// 데이터베이스에서 설정을 비동기적으로 가져와 `isNotificationOn` 프로퍼티를 업데이트함.
  /// 만약 저장된 설정이 없다면 기본값(`false`)으로 새로운 설정을 생성하고 UI 상태를 업데이트함.
  /// 마지막으로, 현재 시스템의 알림 권한 상태를 확인하여 `isSystemGranted`를 갱신하고 데이터 정합성을 맞춤.
  @MainActor
  func loadSetting() async {
    // 설정 데이터를 로드함
    if let existingSetting = await settingStore.fetchSetting() {
      // UI 상태를 업데이트함
      self.isNotificationOn = existingSetting.isNotificationOn
    } else {
      // 설정 데이터가 없을 경우 기본값으로 생성함
      await settingStore.updateNotificationSetting(false)
      self.isNotificationOn = false
    }
    
    await refreshSystemAuth()
    
    // 시스템 권한이 없는데 토글이 ON 상태일 경우, OFF로 강제하여 정합성을 유지함
    if isNotificationOn && !isSystemGranted {
      self.isNotificationOn = false
      await settingStore.updateNotificationSetting(false)
    }
  }
  
  /// 현재 시스템의 알림 권한 상태를 확인하고 `isSystemGranted` 프로퍼티를 갱신함.
  ///
  /// `UNUserNotificationCenter`를 통해 권한 상태를 조회하며, `.authorized`, `.provisional`, `.ephemeral` 상태를 '권한 있음'으로 간주함.
  @MainActor
  func refreshSystemAuth() async {
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    self.isSystemGranted = (status == .authorized || status == .provisional || status == .ephemeral)
  }
  
  /// 앱의 알림 설정과 시스템 권한 상태를 동기화하여 알림 스케줄을 최신화함.
  ///
  /// 이 메서드는 `isSystemGranted`와 `isNotificationOn` 상태를 모두 확인함.
  /// 두 조건이 모두 충족되면 모든 루틴 알림을 스케줄링하고, 그렇지 않다면 예정되거나 전달된 모든 알림을 취소함.
  @MainActor
  func refreshAndSync() async {
    await refreshSystemAuth()
    
    // 권한 및 설정이 모두 ON일 때만 알림을 스케줄링함
    if isSystemGranted && isNotificationOn {
      await RoutineNotificationScheduler().scheduleAll()
    } else {
      NotificationManager.shared.cancelAllIncludingDelivered()
    }
  }
  
  /// 사용자의 알림 설정 변경사항을 적용하고 관련 사이드 이펙트를 처리함.
  ///
  /// - Parameter value: 사용자가 토글한 새로운 알림 설정 값 (`true` 또는 `false`).
  ///
  /// 이 메서드는 다음 순서로 동작함:
  /// 1. UI 상태(`isNotificationOn`)를 즉시 업데이트하여 사용자에게 빠른 피드백을 제공함.
  /// 2. `SettingStore`를 통해 변경된 값을 데이터베이스에 비동기적으로 저장함.
  /// 3. `NotificationManager`를 통해 시스템에 알림 권한을 요청하거나, 설정 비활성화에 따른 알림 취소를 진행함.
  /// 4. 권한 요청 결과에 따라 알림을 스케줄링하거나, 권한이 거부된 경우 UI 상태를 롤백함.
  /// 5. 최종 시스템 권한 상태를 다시 확인하여 `isSystemGranted` 프로퍼티를 업데이트함.
  @MainActor
  func updateNotificationSetting(_ value: Bool) async {
    // 1. UI를 즉시 반영함
    self.isNotificationOn = value
    
    // 2. 설정값을 비동기로 저장함
    await settingStore.updateNotificationSetting(value)
    
    // 3. 시스템 알림 권한을 처리함
    let result = await NotificationManager.shared.setNotificationsEnabled(value)
    
    if value, result == .enabled {
      // 권한 허용 시, 알림을 스케줄링함
      await RoutineNotificationScheduler().scheduleAll()
    } else if value, result == .denied {
      // 권한 거부 시, UI 상태를 롤백하고 알림을 취소함
      self.isNotificationOn = false
      await settingStore.updateNotificationSetting(false)
      NotificationManager.shared.cancelAllIncludingDelivered()
    } else if !value {
      // 토글 OFF 시, 모든 알림을 취소함
      NotificationManager.shared.cancelAllIncludingDelivered()
    }
    
    // 4. 최종 권한 상태를 UI에 반영함
    await refreshSystemAuth()
  }
}

