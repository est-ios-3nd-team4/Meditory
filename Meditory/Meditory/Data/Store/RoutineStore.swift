import Foundation
import SwiftData


// add 는 따로 객체를 미리 만들고 DB에 추가하는 함수
// create 는 이 함수에서 객체까지 만들면서 한방에 DB에 추가하는 함수



final class RoutineStore {

  // MARK: - Load
  /// Routine 객체를 DB에서 로드하는 함수
  @MainActor
  func fetchAllRoutines(context: ModelContext) -> [Routine] {
    let descriptor = FetchDescriptor<Routine>()
    return (try? context.fetch(descriptor)) ?? []
  }

  /// 선택한 날짜에 활성화된 Routine만 불러오는 함수
  @MainActor
  func fetchRoutines(for date: Date, context: ModelContext) -> [Routine] {
    let predicate = #Predicate<Routine> { $0.startDate <= date }
    let descriptor = FetchDescriptor<Routine>(predicate: predicate)
    return (try? context.fetch(descriptor)) ?? []
  }


  // MARK: - Routine
  /// Routine 객체를 DB에 추가하는 함수
  @MainActor
  func addRoutine(_ routine: Routine, context: ModelContext) {
    context.insert(routine)
    try? context.save()
  }

  /// 새로운 Routine 객체를 생성하고 DB에 추가하는 함수
  @MainActor
  func createRoutine(
    type: Int,
    name: String,
    cycleType: Int,
    cycleValue: [Int],
    startDate: Date,
    timesPerDay: Int,
    pillsPerDose: Int,
    memo: String? = nil,
    hasPush: Bool,
    imageData: Data? = nil,
    productName: String? = nil,
    productDescription: String? = nil,
    notWith: String? = nil,
    whenToTake: String? = nil,
    context: ModelContext
  ) {
    let routine = Routine(
      type: type,
      name: name,
      cycleType: cycleType,
      cycleValue: cycleValue,
      startDate: startDate,
      timesPerDay: timesPerDay,
      pillsPerDose: pillsPerDose,
      memo: memo,
      hasPush: hasPush,
      imageData: imageData,
      productName: productName,
      productDescription: productDescription,
      notWith: notWith,
      whenToTake: whenToTake
    )
    context.insert(routine)
    try? context.save()
  }

  /// Routine 하나만 삭제하는 함수
  @MainActor
  func deleteRoutine(_ routine: Routine, context: ModelContext) {
    context.delete(routine)
    try? context.save()
  }

  /// 모든 Routine을 삭제하는 함수
  @MainActor
  func deleteAllRoutines(context: ModelContext) {
    let routines = fetchAllRoutines(context: context)
    for routine in routines {
      context.delete(routine)
    }
    try? context.save()
  }

  // MARK: - RoutineTime
  /// 기존에 생성된 RoutineTime 객체를 특정 Routine에 추가하고 DB에 저장하는 함수
  @MainActor
  func addRoutineTime(_ routineTime: RoutineTime, to routine: Routine, context: ModelContext) {
    routineTime.routine = routine
    routine.routineTimes.append(routineTime)
    context.insert(routineTime)
    try? context.save()
  }

  /// 새로운 RoutineTime 객체를 생성하여 특정 Routine에 추가하고 DB에 저장하는 함수
  @MainActor
  func createRoutineTime(time: Date, for routine: Routine, context: ModelContext) {
    let routineTime = RoutineTime(time: time, routine: routine)
    routine.routineTimes.append(routineTime)
    context.insert(routineTime)
    try? context.save()
  }

  // MARK: - RoutineRecord
  /// 기존에 생성된 RoutineRecord 객체를 특정 Routine에 추가하고 DB에 저장하는 함수
  @MainActor
  func addRoutineRecord(_ record: RoutineRecord, to routine: Routine, context: ModelContext) {
    record.routine = routine
    context.insert(record)
    try? context.save()
  }

  /// 새로운 RoutineRecord 객체를 생성하여 특정 Routine에 추가하고 DB에 저장하는 함수
  @MainActor
  func createRoutineRecord(for routine: Routine, timestamp: Date = Date(), context: ModelContext) {
    let record = RoutineRecord(timestamp: timestamp, routine: routine)
    context.insert(record)
    try? context.save()
  }
}
