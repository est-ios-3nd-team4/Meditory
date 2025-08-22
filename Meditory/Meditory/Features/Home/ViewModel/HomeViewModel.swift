//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var items: [IntakeItem] = []
  @Published var dayCompletionMap: DayCompletionMap = [:]
  
  var progress: Double {
    guard !items.isEmpty else { return 0 }
    let doneCount = items.filter { $0.isCompleted }.count
    return Double(doneCount) / Double(items.count)
  }
  
  private var manager: HomeRoutineManager?
  
  init() { }

  init(context: ModelContext) {
    configureManager(with: context)
  }

  func updateContext(_ context: ModelContext) {
    configureManager(with: context)
  }

  private func configureManager(with context: ModelContext) {
    manager = HomeRoutineManager(context: context)
  }

  /// 오늘 기준 섭취할 영양제 불러오기
  func loadIntake(on date: Date) {
    items = manager?.fetchTodayIntakeItem(on: date) ?? []
  }

  /// 인덱스에 해당하는 IntakeItem 토글 처리
  func toggleCompleted(at index: Int, for date: Date) {
    guard let manager = manager else {
      items[index].isCompleted.toggle()
      return
    }
    manager.toggleIntake(items[index])
    loadIntake(on: date)
    refreshTodayCompletion(on: date)
  }

  func reloadDayCompletions(for baseDate: Date) {
    guard let manager = manager else { dayCompletionMap = [:]; return }
    
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
      let (done, total) = manager.dayCount(on: cursor)
      if total > 0 {
        map[cal.startOfDay(for: cursor)] = Double(done) / Double(total)
      }
      cursor = cal.date(byAdding: .day, value: 1, to: cursor)!
    }
    dayCompletionMap = map
  }
  
  /// 오늘만 빠르게 반영(토글 직후)
  func refreshTodayCompletion(on day: Date) {
    guard let manager = manager else { return }
    let cal = Calendar.current
    let (done, total) = manager.dayCount(on: day)
    let key = cal.startOfDay(for: day)
    if total > 0 {
      dayCompletionMap[key] = Double(done) / Double(total)
    } else {
      dayCompletionMap[key] = nil
    }
  }
}
