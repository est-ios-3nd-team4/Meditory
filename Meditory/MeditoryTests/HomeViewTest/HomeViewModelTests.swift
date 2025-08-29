//
//  HomeViewModelTests.swift
//  MeditoryTests
//
//  Created by Test on 2025/08/25
//

import XCTest
@testable import Meditory

final class HomeViewModelTests: XCTestCase {

  private let cal = Calendar.current

  // 더미 Routine (SwiftData 저장/컨텍스트 불필요)
  private func dummyRoutine(name: String = "더미") -> Routine {
    Routine(
      type: 1,
      displayName: name,
      desc: nil,
      category: nil,
      cycleType: 1,
      cycleValue: "0,1,2,3,4,5,6",
      startDate: Date(),
      memo: nil,
      hasPush: true,
      usage: [],
      precautions: [],
      routineTimes: [],
      recommendedRoutineTimes: []
    )
  }

  // 테스트용 IntakeItem 생성
  private func makeItem(
    name: String,
    hour: Int,
    minute: Int,
    isCompleted: Bool,
    baseDay: Date = Date()
  ) -> IntakeItem {
    var comp = cal.dateComponents([.year, .month, .day], from: cal.startOfDay(for: baseDay))
    comp.hour = hour; comp.minute = minute; comp.second = 0
    let time = cal.date(from: comp)!

    return IntakeItem(
      id: UUID(),
      name: name,
      time: time,
      isCompleted: isCompleted,
      routine: dummyRoutine(name: name)
    )
  }

  /// 아이템이 없을 때 progress는 0
  func test_progress_isZero_whenNoItems() {
    let vm = HomeViewModel() // 본 코드 수정 없음 (기본 init)
    vm.intakeItems = []
    XCTAssertEqual(vm.progress, 0.0, accuracy: 0.0001)
  }

  /// 완료/미완료 조합에 따라 progress 계산이 맞는지 확인
  func test_progress_computation_matchesCompletedRatio() {
    let day = cal.startOfDay(for: Date())
    let vm = HomeViewModel()

    vm.intakeItems = [
      makeItem(name: "A", hour: 8,  minute: 0,  isCompleted: false, baseDay: day),
      makeItem(name: "B", hour: 12, minute: 0,  isCompleted: true,  baseDay: day),
      makeItem(name: "C", hour: 20, minute: 30, isCompleted: false, baseDay: day),
    ]
    // 1/3
    XCTAssertEqual(vm.progress, 1.0/3.0, accuracy: 0.0001)

    // 두 번째 아이템만 완료였다가, 첫 번째도 완료로 변경 → 2/3
    vm.intakeItems[0].isCompleted = true
    XCTAssertEqual(vm.progress, 2.0/3.0, accuracy: 0.0001)

    // 모두 완료 → 3/3 = 1.0
    vm.intakeItems[2].isCompleted = true
    XCTAssertEqual(vm.progress, 1.0, accuracy: 0.0001)
  }

  /// dayCompletionMap을 직접 갱신했을 때, 값이 정상 반영되는지 확인
  func test_dayCompletionMap_manualUpdate() {
    let vm = HomeViewModel()
    let today = cal.startOfDay(for: Date())
    let tomorrow = cal.date(byAdding: .day, value: 1, to: today)!

    vm.dayCompletionMap = [:]
    vm.dayCompletionMap[today] = 0.5
    vm.dayCompletionMap[cal.startOfDay(for: tomorrow)] = 1.0

    XCTAssertEqual(vm.dayCompletionMap[today]!, 0.5, accuracy: 0.0001)
    XCTAssertEqual(vm.dayCompletionMap[cal.startOfDay(for: tomorrow)]!, 1.0, accuracy: 0.0001)
  }
}
