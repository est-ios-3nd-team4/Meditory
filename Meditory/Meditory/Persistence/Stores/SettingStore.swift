import Foundation
import SwiftData

/// `Setting` 관련 SwiftData 작업을 처리하는 ModelActor임.
///
/// 이 액터는 앱의 데이터베이스 컨텍스트에서 설정 데이터의 생성, 조회, 수정, 삭제 작업을 스레드에 안전하게 관리함.
@ModelActor
actor SettingStore {
  /// 앱 전역에서 접근 가능한 공유 싱글턴 인스턴스임.
  static let shared = SettingStore(modelContainer: DataController.shared.container)
  
  /// 데이터베이스에 저장된 `Setting` 객체를 조회함.
  ///
  /// 설정 객체는 하나만 존재하므로, 조회된 첫 번째 객체를 반환함.
  /// - Returns: 조회된 `Setting` 객체. 객체가 없으면 `nil`을 반환함.
  func fetchSetting() -> Setting? {
    let descriptor = FetchDescriptor<Setting>()
    return try? modelContext.fetch(descriptor).first
  }
  
  /// 알림 활성화 설정을 업데이트하고 데이터베이스에 저장함.
  ///
  /// 기존 `Setting` 객체가 있으면 해당 객체의 `isNotificationOn` 값을 수정하고, 없으면 새로운 `Setting` 객체를 생성하여 저장함.
  /// - Parameter value: 설정할 알림 활성화 상태 (`true` 또는 `false`).
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
  
  /// 데이터베이스에 저장된 `Setting` 객체를 삭제함.
  ///
  /// 모든 설정 정보를 초기화할 때 사용할 수 있음.
  func deleteSetting() {
    if let setting = fetchSetting() {
      modelContext.delete(setting)
      try? modelContext.save()
    }
  }
}
