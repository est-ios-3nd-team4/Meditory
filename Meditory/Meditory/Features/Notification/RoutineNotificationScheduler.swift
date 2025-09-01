//
//  RoutineNotificationScheduler.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import Foundation
import UserNotifications
import SwiftData

/// 루틴(`Routine`) 정보를 바탕으로 **로컬 알림을 스케줄링**하는 유틸리티입니다.
/// - 역할:
///   - 시스템 권한 및 앱 설정 토글 상태를 확인한 뒤, 루틴 주기 타입에 맞게 알림을 예약합니다.
///   - 요일 반복(weekly)과 간격 반복(interval) 두 가지 방식을 지원합니다.
///   - 전체 재스케줄/단일 루틴 재스케줄을 위한 편의 메서드를 제공합니다.
/// - 스레드:
///   - UNUserNotificationCenter의 비동기 API 사용. 호출 측에서 `await`로 관리하십시오.
struct RoutineNotificationScheduler {
  /// 알림 스케줄에 사용하는 캘린더(한국 로케일, 현재 타임존)
  private let calendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "ko_KR")
    cal.timeZone = .current
    return cal
  }()

  // MARK: - Public APIs

  /// 단일 루틴에 대한 알림을 스케줄합니다.
  /// - 동작:
  ///   1. 시스템 알림 권한(authorized/provisional/ephemeral) 확인
  ///   2. 앱 내부 알림 토글(`SettingStore.isNotificationOn`) 확인
  ///   3. 루틴의 `cycleType`에 따라 주기별 스케줄 메서드 호출
  /// - Parameter routine: 스케줄할 대상 루틴
  func schedule(for routine: Routine) async {
    // 시스템 권한 및 앱 토글 확인
    let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    let systemGranted = (status == .authorized || status == .provisional || status == .ephemeral)

    // SettingStore의 앱 토글
    let appOn = await (SettingStore.shared.fetchSetting()?.isNotificationOn ?? false)

    guard systemGranted && appOn else { return }

    switch routine.cycleType {
    case 1: try? await scheduleWeekly(for: routine)
    case 2: try? await scheduleInterval(for: routine)
    default: break
    }
  }

  /// 앱에 등록된 모든 `Routine`에 대해 알림 스케줄을 재설정합니다.
  ///
  /// - 동작 과정:
  ///   1. `RoutineStore` 액터에서 모든 Routine의 식별자(ID)를 가져옵니다.
  ///   2. 메인 컨텍스트(`mainContext`)에서 ID에 해당하는 최신 Routine 객체를 조회합니다.
  ///      - 이렇게 하면 컨텍스트 불일치로 인한 관계(`routineTimes`) 누락 문제를 방지합니다.
  ///   3. 각 Routine에 대해 기존 예약 알림을 취소한 뒤, `schedule(for:)`를 호출하여 다시 스케줄링합니다.
  ///
  /// - 주의사항:
  ///   - 반드시 `@MainActor`에서 실행되어야 합니다. (SwiftData 모델 및 UNUserNotificationCenter 호출 일관성 보장)
  ///   - Routine 관계(`routineTimes`)는 스케줄 계산에 필수이므로,
  ///     메인 컨텍스트에서 재조회한 객체를 사용해야 누락/지연 문제를 피할 수 있습니다.
  ///
  /// - 결과:
  ///   - 모든 Routine의 알림 예약이 취소 후 재생성되며, UI/데이터 일관성이 보장됩니다.
  @MainActor
  func scheduleAll() async {
    let ids = await RoutineStore.shared.fetchAllRoutineIDs()

    let context = DataController.shared.container.mainContext
    var routines: [Routine] = []
    for pid in ids {
      if let routine: Routine = context.model(for: pid) as? Routine {
        routines.append(routine)
      }
    }

    for routine in routines {
      NotificationManager.shared.cancelForRoutineID(routine.id)
      await schedule(for: routine)
    }
  }

  /// 특정 루틴 변경 후 **재스케줄**합니다.
  /// - Note: 기존 동일 루틴 관련 예약/전달 알림을 먼저 취소한 후 다시 예약합니다.
  /// - Parameter routine: 재스케줄할 루틴
  func reschedule(routine: Routine) async {
    NotificationManager.shared.cancelForRoutineID(routine.id)
    await schedule(for: routine)
  }
}

// MARK: - Private Scheduling Helpers
private extension RoutineNotificationScheduler {
  /// 요일 반복(Weekly) 루틴 알림을 스케줄합니다.
  /// - 규칙:
  ///   - 내부 요일 인덱스(일=0…토=6)를 `UNCalendar` 요일(일=1…토=7)로 변환하여 사용합니다.
  ///   - 각 `RoutineTime`에 대해 설정된 시/분으로 반복 트리거를 설정합니다.
  ///   - 알림 ID는 `RoutineFormatter.weeklyNotificationID` 규칙을 따릅니다.
  /// - Parameter routine: 대상 루틴 (`cycleType == 1`)
  func scheduleWeekly(for routine: Routine) async throws {
    // 일=1 ... 토=7 (UNCalendar 규칙 적용된 값)
    let unCalWeekdays = RoutineFormatter.unCalendarWeekdays(from: routine.cycleValue)
    guard !unCalWeekdays.isEmpty else { return }

    for t in routine.routineTimes {
      let hour = calendar.component(.hour, from: t.time)
      let minute = calendar.component(.minute, from: t.time)

      let hhmm = t.time.formattedString("HHmm", calendar: calendar)

      for w in unCalWeekdays {
        var dc = DateComponents()
        dc.weekday = w
        dc.hour = hour
        dc.minute = minute
        dc.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
        let id = RoutineFormatter.weeklyNotificationID(
          routineID: routine.id,
          unCalWeekday: w,
          hhmm: hhmm
        )

        let info: [String:String] = [
          "routineUUID" : routine.id.uuidString,
          "displayName" : routine.displayName,
          "routineTimeUUID" : t.id.uuidString
        ]

        await NotificationManager.shared.scheduleRoutineNotification(
          id: id,
          title: "복용 알림",
          body: "\(routine.displayName)\(routine.displayName.eulReul()) 섭취하실 시간이에요!",
          userInfo: info,
          trigger: trigger
        )
      }
    }
  }

  /// 간격 반복(Interval) 루틴 알림을 스케줄합니다.
  /// - 규칙:
  ///   - `RoutineFormatter.intervalDays` 규칙(내부 보정: -10, 최소 1일)을 적용하여 간격일 계산
  ///   - 루틴 시작일의 **날짜** + `RoutineTime`의 **시/분**을 결합하여 시작 시각 생성
  ///   - 현재 시점 이후로 끌어올려 **N회(occurrences)** 예약합니다(기본 30회)
  ///   - 알림 ID는 `RoutineFormatter.oneOffNotificationID` 규칙을 따릅니다.
  /// - Parameter routine: 대상 루틴 (`cycleType == 2`)
  func scheduleInterval(for routine: Routine) async throws {
    // 내부 보정 규칙(-10, 최소 1일)을 적용한 실제 간격일
    let intervalDays = RoutineFormatter.intervalDays(from: routine.cycleValue) ?? 1
    let occurrences = 30  // 필요 시 프로젝트 상수로 분리

    for t in routine.routineTimes {
      // 루틴 시작일의 날짜 + 해당 복용시간의 시/분
      let start = routine.startDate.mergingTime(from: t.time, calendar: calendar)
        .advancedToNow(byDayInterval: intervalDays, calendar: calendar)

      // 현재 시점 이후로 끌어올려 앞으로 N회 생성
      let dates = start.nextDates(everyDays: intervalDays, occurrences: occurrences, calendar: calendar)

      for date in dates {
        let id = RoutineFormatter.oneOffNotificationID(
          routineID: routine.id,
          date: date,
          calendar: calendar
        )
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let info: [String:String] = [
          "routineUUID": routine.id.uuidString,
          "displayName": routine.displayName,
          "routineTimeUUID": t.id.uuidString
        ]

        await NotificationManager.shared.scheduleRoutineNotification(
          id: id,
          title: "복용 알림",
          body: "\(routine.displayName)\(routine.displayName.eulReul()) 섭취하실 시간이에요!",
          userInfo: info,
          trigger: trigger
        )
      }
    }
  }
}
