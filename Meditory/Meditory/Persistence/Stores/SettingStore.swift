import Foundation
import SwiftData

// UserStore와 동일한 @ModelActor 패턴을 적용하여 변경

@ModelActor
actor SettingStore {
  static let shared = SettingStore(modelContainer: DataController.shared.container)
  
  /// 현재 설정 정보를 가져오는 public 함수
  func fetchSetting() -> Setting? {
    let descriptor = FetchDescriptor<Setting>()
    return try? modelContext.fetch(descriptor).first
  }
  
  /// 알림 설정을 업데이트하는 함수 (없으면 새로 생성)
  func updateNotificationSetting(_ value: Bool) {
    if let setting = fetchSetting() {
      setting.isNotificationOn = value
    } else {
      let newSetting = Setting(isNotificationOn: value)
      modelContext.insert(newSetting)
    }
    
    // 작업이 끝난 후 한 번만 저장을 시도
    try? modelContext.save()
  }
  
  /// 모든 설정 정보를 삭제하는 함수 (초기화 등에 사용)
  func deleteSetting() {
    if let setting = fetchSetting() {
      modelContext.delete(setting)
      try? modelContext.save()
    }
  }
}
