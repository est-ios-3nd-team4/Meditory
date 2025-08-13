//
//  HomeRoutineManager.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//


import Foundation
import SwiftData

@MainActor
final class HomeRoutineManager {
  private let context: ModelContext
  private let routineStore: RoutineStore

  /// ModelContext와 RoutineStore를 주입받아 초기화
  init(context: ModelContext, routineStore: RoutineStore = RoutineStore()) {
    self.context = context
    self.routineStore = routineStore
  }

  /// 단일 RoutineRecord 삭제
  func delete(record: RoutineRecord) {
    context.delete(record)
    try? context.save()
  }

  /// 특정 루틴/시간에 레코드가 있는지 여부
  func isCompleted(routine: Routine, at time: Date) -> Bool {
    let allRecords = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []

    return allRecords.contains { record in
      record.routine == routine &&
      Calendar.current.isDate(record.timestamp,
                              equalTo: time,
                              toGranularity: .minute)
    }
  }

  /// 오늘 날짜 기준 IntakeItem 목록 생성
  func fetchTodayIntakeItem(on date: Date) -> [IntakeItem] {
    let calendar = Calendar.current
    let routines = routineStore.fetchRoutines(for: date, context: context)
    var items: [IntakeItem] = []

    for routine in routines {
      for time in routine.routineTimes {
        // RoutineTime.time의 시분초만 추출
        var components = calendar.dateComponents([.hour, .minute, .second], from: time.time)

        // 선택한 날짜의 연월일을 덧씌움
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        components.year = dayComponents.year
        components.month = dayComponents.month
        components.day = dayComponents.day

        guard let scheduledTime = calendar.date(from: components) else { continue }

        let completed = isCompleted(routine: routine, at: scheduledTime)
        items.append(
          IntakeItem(
            id: time.id,
            name: routine.category ?? "",
            time: scheduledTime,
            isCompleted: completed,
            routine: routine
          )
        )
      }
    }

    return items.sorted { $0.time < $1.time }
  }

  /// IntakeItem 체크/낫체크 토글: 레코드 생성 또는 삭제
  func toggleIntake(_ item: IntakeItem) {
    let allRecords = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []

    if item.isCompleted {
      // 이미 체크된 상태: 해당 시간의 레코드만 삭제
      if let deleteRecord = allRecords.first(where: { record in
        record.routine == item.routine &&
        Calendar.current.isDate(record.timestamp,
                                equalTo: item.time,
                                toGranularity: .minute)
      }) {
        delete(record: deleteRecord)
      }
    } else {
      // 체크 안 된 상태: 새 레코드 생성
      routineStore.createRoutineRecord(
        for: item.routine,
        timestamp: item.time,
        context: context
      )
    }
  }
}
