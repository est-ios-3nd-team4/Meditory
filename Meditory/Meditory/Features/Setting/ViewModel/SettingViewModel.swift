import Foundation
import SwiftUI
import SwiftData

class SettingViewModel: ObservableObject {
  @Published var isNotificationOn: Bool = false

  private let settingStore: SettingStore = SettingStore()

  private var setting: Setting?

//  init() {}

  @MainActor
  func loadSetting(context: ModelContext) {
      if let existing = settingStore.fetchSetting(context: context) {
          self.setting = existing
          self.isNotificationOn = existing.isNotificationOn
      } else {
          // 없으면 기본값으로 생성
          settingStore.createSetting(isNotificationOn: false, context: context)
          if let created = settingStore.fetchSetting(context: context) {
              self.setting = created
              self.isNotificationOn = created.isNotificationOn
          } else {
              // 예외 상황 대비 기본값 유지
              self.setting = nil
              self.isNotificationOn = false
          }
      }
  }

  @MainActor
  func updateNotificationSetting(_ value: Bool, context: ModelContext) {
      // ViewModel 상태 업데이트 + Store 통해 영속화
      self.isNotificationOn = value
      settingStore.updateNotificationSetting(value, context: context)
      // 최신 Setting 참조 갱신
      self.setting = settingStore.fetchSetting(context: context)
  }

}
