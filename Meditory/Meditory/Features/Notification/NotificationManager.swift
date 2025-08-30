//
//  NotificationManager.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import Foundation
@preconcurrency import UserNotifications
import UIKit

enum NotificationToggleResult {
  case enabled   // 권한 허용
  case denied    // 거부 또는 요청 실패
}

final class NotificationManager {
  static let shared = NotificationManager()
  private init() {}

  /// 앱 토글 ON/OFF 시 진입. 샘플 예약 없이 권한만 확인/요청하고 결과 반환.
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

  // 최초/필요 시 권한 요청
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

  // iOS 설정 앱 열기
  func openSystemSettings() {
    DispatchQueue.main.async {
      guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
      UIApplication.shared.open(url)
    }
  }

  // 알림 예약
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

  // Pending 전부 취소
  func cancelAll() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
  }

  // 특정 ID들 취소
  func cancel(ids: [String]) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
  }

  // Pending + Delivered 모두 취소 (토글 OFF/앱 시작 동기화 시 권장)
  func cancelAllIncludingDelivered() {
    let center = UNUserNotificationCenter.current()
    center.removeAllPendingNotificationRequests()
    center.removeAllDeliveredNotifications()
  }

  /// 동일 identifier가 pending에 있으면 먼저 제거한 뒤 요청을 등록합니다.
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

  /// 특정 루틴(UUID)의 모든 예약/표시 알림 취소
  /// - identifier 규칙: "routine-<UUID>-..." (요일/주기 모두)
  /// - userInfo["routineUUID"] 매칭도 함께 사용 (규칙 변경 대비)
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
