import Foundation
import SwiftData



final class SettingStore {


  // Setting 전체 조회 (1개만 있을 것)
  @MainActor
  func fetchSetting(context: ModelContext) -> Setting? {
      let descriptor = FetchDescriptor<Setting>()
      return try? context.fetch(descriptor).first
  }

  // Setting 업데이트 (없으면 생성)
  @MainActor
  func updateNotificationSetting(_ value: Bool, context: ModelContext) {
      if let setting = fetchSetting(context: context) {
          setting.isNotificationOn = value
          try? context.save()
      } else {
          createSetting(isNotificationOn: value, context: context)
      }
  }

  // 새 Setting 생성 (보통 1개만 생성)
  @MainActor
  func createSetting(isNotificationOn: Bool, context: ModelContext) {
      let newSetting = Setting(isNotificationOn: isNotificationOn)
      context.insert(newSetting)
      try? context.save()
  }

  // Setting 삭제 (예외적으로 필요할 때만)
  @MainActor
  func deleteSetting(context: ModelContext) {
      if let setting = fetchSetting(context: context) {
          context.delete(setting)
          try? context.save()
      }
  }
}
