import Foundation
import SwiftUI
import SwiftData

// 최신 Swift Concurrency를 위해 @Observable 매크로를 사용
@Observable
class SettingViewModel {
  // UI와 바인딩될 프로퍼티는 그대로 유지
  var isNotificationOn: Bool = false
  
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
  }
  
  @MainActor
  func updateNotificationSetting(_ value: Bool) async {
    // 1. UI 상태를 즉시 업데이트
    self.isNotificationOn = value
    
    // 2. Store를 통해 백그라운드에서 데이터베이스에 비동기적으로 저장
    await settingStore.updateNotificationSetting(value)
  }
}
