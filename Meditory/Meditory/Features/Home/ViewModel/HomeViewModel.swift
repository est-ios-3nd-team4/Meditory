//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import Foundation
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var items: [IntakeItem] = []

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
  }
}
