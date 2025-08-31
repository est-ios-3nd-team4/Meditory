//
//  NotificationManager.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import Foundation
@preconcurrency import UserNotifications
import UIKit

/// 알림 토글 요청에 대한 결과를 나타냅니다.
/// - `enabled`: 권한이 허용되었거나(요청 성공 포함) 토글 OFF 처리 후 성공적으로 정리된 상태
/// - `denied`: 권한이 거부되었거나 요청이 실패한 상태
enum NotificationToggleResult {
  case enabled   // 권한 허용
  case denied    // 거부 또는 요청 실패
}

/// 앱 전반의 **로컬 알림 권한 요청/상태 확인/스케줄 관리**를 담당하는 매니저입니다.
/// - 특징:
///   - 싱글턴으로 제공(`shared`)되어 어디서든 동일 인스턴스를 사용합니다.
///   - iOS 시스템 권한 흐름 및 예약/취소 동작을 캡슐화합니다.
/// - 권장 사용 시나리오:
///   - 설정 화면에서 알림 토글 시 `setNotificationsEnabled(_:)` 호출
///   - 루틴 알림 예약 시 `scheduleRoutineNotification(...)` 또는 `addRequest(...)` 호출
///   - 동기화/로그아웃 등 전체 취소 시 `cancelAllIncludingDelivered()` 호출
final class NotificationManager {
  /// 전역 싱글턴 인스턴스
  static let shared = NotificationManager()
  private init() {}
  
  /// 앱의 알림 기능 토글 시 호출되는 진입점입니다.
  /// - 동작:
  ///   - `enabled == false`면 예약/전달된 모든 알림을 제거 후 `.enabled` 반환
  ///   - `enabled == true`면 현재 권한 상태를 확인:
  ///     - 미결정(`.notDetermined`) → 권한 요청 → 허용 시 `.enabled`, 거부 시 `.denied`
  ///     - 거부(`.denied`) → `.denied`
  ///     - 허용/임시 허용(`.authorized`/`.provisional`/`.ephemeral`) → `.enabled`
  /// - Parameter enabled: 사용자가 알림을 켰는지 여부
  /// - Returns: `NotificationToggleResult`
  func setNotificationsEnabled(_ enabled: Bool) async -> NotificationToggleResult {
    if !enabled {
      cancelAllIncludingDelivered()
      return .enabled
    }
    
    let center = UNUserNotificationCenter.current()
    let settings = await center.notificationSettings()
    
    switch settings.authorizationStatus {
    case .notDetermined:
      let granted = await requestAuthorization()
      return granted ? .enabled : .denied
      
    case .denied:
      return .denied
      
    case .authorized, .provisional, .ephemeral:
      return .enabled
      
    @unknown default:
      return .denied
    }
  }
  
  /// 사용자에게 알림 권한을 요청합니다.
  /// - Returns: 권한 허용 시 `true`, 거부/오류 시 `false`
  /// - Note: `.alert`, `.sound`, `.badge` 옵션으로 요청합니다.
  func requestAuthorization() async -> Bool {
    do {
      let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
      
      if !granted {
        print("알림 권한 거부됨")
      }
      return granted
    } catch {
      print("권한 요청 실패: \(error)")
      return false
    }
  }
  
  /// iOS 시스템 설정 앱의 본 앱 상세 설정 화면을 엽니다.
  /// - Note: 메인 스레드에서 URL 오픈을 수행합니다.
  func openSystemSettings() {
    DispatchQueue.main.async {
      guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
      UIApplication.shared.open(url)
    }
  }
  
  /// 주어진 파라미터로 **로컬 알림을 예약**합니다.
  /// - 기존 동일 식별자 알림이 Pending 상태라면 먼저 제거합니다.
  /// - Parameters:
  ///   - id: 알림 식별자(고유)
  ///   - title: 알림 제목
  ///   - body: 알림 본문
  ///   - userInfo: 알림과 함께 전달할 사용자 정보(기본값 `[:]`)
  ///   - trigger: `UNNotificationTrigger` (시간/달력/지역 등)
  /// - Note: 예약 실패 시 콘솔에 에러를 출력합니다.
  func addRequest(
    id: String,
    title: String,
    body: String,
    userInfo: [AnyHashable: Any] = [:],
    trigger: UNNotificationTrigger
  ) async {
    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: [id])
    
    let content = UNMutableNotificationContent()
    content.title = title
    content.body  = body
    content.sound = .default
    content.userInfo = userInfo
    
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    do {
      try await center.add(request)
    } catch {
      print("스케줄 실패(\(id)): \(error)")
    }
  }
  
  /// 모든 **Pending** 알림을 취소합니다.
  func cancelAll() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }
  
  /// 지정한 식별자들의 **Pending** 알림을 취소합니다.
  /// - Parameter ids: 취소할 식별자 배열
  func cancel(ids: [String]) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
  }
  
  /// **Pending + Delivered** 알림을 모두 취소합니다.
  /// - 권장 사용: 토글 OFF, 앱 시작 시 동기화 등
  func cancelAllIncludingDelivered() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
  }
  
  /// 루틴 알림을 스케줄합니다. 동일 identifier가 Pending에 있으면 먼저 제거한 뒤 등록합니다.
  /// - Parameters:
  ///   - id: 알림 식별자(고유)
  ///   - title: 제목
  ///   - body: 본문
  ///   - userInfo: `"routineUUID"`(문자열) 등 부가 정보. 스레드 분류에 사용됩니다.
  ///   - trigger: 트리거(시간/달력/반복 등)
  /// - Note:
  ///   - `interruptionLevel = .timeSensitive`로 설정되어 중요 알림으로 분류됩니다.
  ///   - `userInfo["routineUUID"]`가 있으면 `threadIdentifier`를 `routine-{UUID}`로 설정합니다.
  func scheduleRoutineNotification(id: String, title: String, body: String,userInfo: [String:String], trigger: UNNotificationTrigger) async {
    let center = UNUserNotificationCenter.current()
    
    await withCheckedContinuation { cont in
      center.getPendingNotificationRequests { reqs in
        let dup = reqs.filter { $0.identifier == id }.map(\.identifier)
        if !dup.isEmpty {
          center.removePendingNotificationRequests(withIdentifiers: dup)
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = userInfo
        content.interruptionLevel = .timeSensitive
        if let rid = userInfo["routineUUID"] {
          content.threadIdentifier = "routine-\(rid)"
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
        cont.resume()
      }
    }
  }
  
  /// 특정 루틴(UUID)에 해당하는 모든 **예약/전달** 알림을 취소합니다.
  /// - 규칙:
  ///   - identifier prefix: `"routine-<UUID>-"`
  ///   - `userInfo["routineUUID"] == <UUID>` 매칭도 함께 확인 (규칙 변경 대비)
  /// - Parameter uuid: 루틴 고유 식별자(UUID)
  func cancelForRoutineID(_ uuid: UUID) {
    let center = UNUserNotificationCenter.current()
    let prefix = "routine-\(uuid.uuidString)-"
    
    // Pending 취소
    center.getPendingNotificationRequests { reqs in
      var ids = reqs
        .filter { $0.identifier.hasPrefix(prefix) }
        .map(\.identifier)
      
      let userInfoMatched = reqs
        .filter { ($0.content.userInfo["routineUUID"] as? String) == uuid.uuidString }
        .map(\.identifier)
      
      ids.append(contentsOf: userInfoMatched)
      ids = Array(Set(ids))
      if !ids.isEmpty {
        center.removePendingNotificationRequests(withIdentifiers: ids)
        print("예약된 알림 \(ids.count)개가 \(uuid)에서 제거되었습니다.")
      }
    }
    
    // Delivered 취소
    center.getDeliveredNotifications { delivered in
      var ids = delivered
        .map(\.request)
        .filter { $0.identifier.hasPrefix(prefix) }
        .map(\.identifier)
      
      let userInfoMatched = delivered
        .filter { ($0.request.content.userInfo["routineUUID"] as? String) == uuid.uuidString }
        .map { $0.request.identifier }
      
      ids.append(contentsOf: userInfoMatched)
      ids = Array(Set(ids))
      if !ids.isEmpty {
        center.removeDeliveredNotifications(withIdentifiers: ids)
        print("이미 전달된 알림 \(ids.count)개가 \(uuid)에서 제거되었습니다.")
      }
    }
  }
}
