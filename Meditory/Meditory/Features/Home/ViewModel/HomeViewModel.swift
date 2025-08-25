//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import Foundation
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {
  var intakeItems: [IntakeItem] = []
  var dayCompletionMap: DayCompletionMap = [:]
  
  var progress: Double {
    guard !intakeItems.isEmpty else { return 0 }
    let doneCount = intakeItems.filter { $0.isCompleted }.count
    return Double(doneCount) / Double(intakeItems.count)
  }
  
  init() { }

  /// 오늘 기준 섭취할 영양제 불러오기 (비동기 함수로 변경)
  @MainActor
  func loadIntake(on date: Date) async {
    intakeItems = await HomeRoutineManager.shared.fetchTodayIntakeItems(on: date)
  }

  /// IntakeItem 토글 처리 (비동기 함수로 변경)
  @MainActor
  func toggleCompleted(_ item: IntakeItem, for date: Date) async {
    await HomeRoutineManager.shared.toggleIntake(item)
    await loadIntake(on: date) // 데이터를 다시 로드
    await refreshTodayCompletion(on: date) // 달력 UI 갱신
  }

  /// 월간 달력의 완료 상태를 비동기로 다시 로드
  @MainActor
  func reloadDayCompletions(for baseDate: Date) async {
    let cal = Calendar.current
    guard
      let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: baseDate)),
      let startOfNext  = cal.date(byAdding: .month, value: 1, to: startOfMonth)
    else {
      dayCompletionMap = [:]
      return
    }
    
    var map: DayCompletionMap = [:]
    var cursor = startOfMonth
    while cursor < startOfNext {
      let (done, total) = await HomeRoutineManager.shared.dayCount(on: cursor)
      if total > 0 {
        map[cal.startOfDay(for: cursor)] = Double(done) / Double(total)
      }
      cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
    }
    dayCompletionMap = map
  }
  
  /// 오늘 날짜의 완료 상태만 빠르게 갱신 (비동기 함수로 변경)
  @MainActor
  func refreshTodayCompletion(on day: Date) async {
    let cal = Calendar.current
    let (done, total) = await HomeRoutineManager.shared.dayCount(on: day)
    let key = cal.startOfDay(for: day)
    if total > 0 {
      dayCompletionMap[key] = Double(done) / Double(total)
    } else {
      dayCompletionMap[key] = nil
    }
  }
}
