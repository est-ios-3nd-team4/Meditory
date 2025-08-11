//
//  DummyRoutineData.swift
//  Meditory
//
//  Created by 윤혜주 on 8/7/25.
//


import Foundation
import SwiftData

@MainActor
struct DummyRoutineData {
  static func seed(into context: ModelContext) {
    let store = RoutineStore()
    let existing = store.fetchAllRoutines(context: context)
    guard existing.isEmpty else { return }

    // MARK: - Dummy Routines
    store.createRoutine(
      type: 1,
      name: "비타민C",
      cycleType: 1,
      cycleValue: "0",   // 매일
      startDate: Date(),
      timesPerDay: 3,
      pillsPerDose: 1,
      memo: nil,
      hasPush: true,
      context: context
    )

    store.createRoutine(
      type: 1,
      name: "오메가-3",
      cycleType: 1,
      cycleValue: "1, 3, 5", // 월, 수, 금
      startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
      timesPerDay: 1,
      pillsPerDose: 2,
      memo: "심장 건강",
      hasPush: false,
      context: context
    )

    store.createRoutine(
      type: 1,
      name: "비타민D",
      cycleType: 2,
      cycleValue: "2",    // 이틀 간격
      startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
      timesPerDay: 1,
      pillsPerDose: 1,
      memo: nil,
      hasPush: true,
      context: context
    )

    // MARK: - Dummy RoutineTimes
    let all = store.fetchAllRoutines(context: context)
    let calendar = Calendar.current

    for routine in all {
      switch routine.name {
      case "비타민C":
        [8, 13, 20].forEach { hour in
          let time = calendar.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: Date()
          )!
          store.createRoutineTime(time: time, for: routine, context: context)
        }

      case "오메가-3":
        let time = calendar.date(
          bySettingHour: 9,
          minute: 30,
          second: 0,
          of: Date()
        )!
        store.createRoutineTime(time: time, for: routine, context: context)

      case "비타민D":
        let time = calendar.date(
          bySettingHour: 12,
          minute: 0,
          second: 0,
          of: Date()
        )!
        store.createRoutineTime(time: time, for: routine, context: context)

      default:
        break
      }
    }
  }
}
