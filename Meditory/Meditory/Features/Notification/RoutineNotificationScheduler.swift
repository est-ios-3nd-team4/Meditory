//
//  RoutineNotificationScheduler.swift
//  Meditory
//
//  Created by 윤혜주 on 8/26/25.
//

import Foundation
import UserNotifications
import SwiftData

struct RoutineNotificationScheduler {
  private let calendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.locale = Locale(identifier: "ko_KR")
    cal.timeZone = .current
    return cal
  }()

  // 외부에서 호출: 루틴 1건 스케줄
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

  // 전체 루틴 일괄 스케줄
  func scheduleAll() async {
    let fetch = FetchDescriptor<Routine>()
    let routines = await RoutineStore.shared.fetchAllRoutines()

    for routine in routines {
      NotificationManager.shared.cancelForRoutineID(routine.id)
      await schedule(for: routine)
    }
  }

  // 변경 시 다시 스케줄 호출
  func reschedule(routine: Routine) async {
    NotificationManager.shared.cancelForRoutineID(routine.id)
    await schedule(for: routine)
  }
}

private extension RoutineNotificationScheduler {
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
