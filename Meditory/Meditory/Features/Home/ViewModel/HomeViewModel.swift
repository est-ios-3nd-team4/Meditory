//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation
import SwiftData

struct IntakeItem: Identifiable {
  let id: UUID
  let name: String
  let time: Date
  var isCompleted: Bool
  var routine: Routine
}

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var items: [IntakeItem] = []
  @Published var progress: Double = 0

  private var context: ModelContext?
  private let routineStore = RoutineStore()

  init() { }

  init(context: ModelContext) {
    self.context = context
    loadTodayIntake()
  }

  func updateContext(_ context: ModelContext) {
    self.context = context
    loadTodayIntake()
  }

  /// 오늘 기준 섭취할 영양제 불러오기
  func loadTodayIntake() {
    guard let context = context else {
      items = []
      progress = 0
      return
    }

    let today = Date()
    let routines = routineStore.fetchRoutines(for: today, context: context)

    var intakeItems: [IntakeItem] = []

    for routine in routines {
      for time in routine.routineTimes {
        let completed = isCompletedToday(routine: routine, context: context)
        let item = IntakeItem(
          id: time.id,
          name: routine.name,
          time: time.time,
          isCompleted: completed,
          routine: routine
        )
        intakeItems.append(item)
      }
    }

    self.items = intakeItems.sorted { $0.time < $1.time }
    calculateProgress()
  }

  private func isCompletedToday(routine: Routine, context: ModelContext) -> Bool {
    let startOfDay = Calendar.current.startOfDay(for: Date())
    let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

    // 이 루틴의 모든 Record를 불러와서 필터링
    let descriptor = FetchDescriptor<RoutineRecord>()
    let records: [RoutineRecord]

    do {
      records = try context.fetch(descriptor)
    } catch {
      print("Fetch 실패:", error)
      records = []
    }
     
    return records.contains { record in
      record.routine == routine &&
      (startOfDay..<endOfDay).contains(record.timestamp)
    }
  }

  func toggleCompleted(at index: Int) {
    guard let context else {
      items[index].isCompleted.toggle()
      calculateProgress()
      return
    }

    let item = items[index]

    if item.isCompleted {
      
    } else {
      routineStore.createRoutineRecord(for: item.routine, context: context)
    }
    loadTodayIntake()
  }

  private func calculateProgress() {
    guard !items.isEmpty else {
      progress = 0
      return
    }
    let done = items.filter { $0.isCompleted }.count
    progress = Double(done) / Double(items.count)
  }
}
