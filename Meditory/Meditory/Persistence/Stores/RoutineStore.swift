import Foundation
import SwiftData

@ModelActor
actor RoutineStore {
  // 앱 전역에서 접근할 수 있는 싱글턴 인스턴스
  static let shared = RoutineStore(modelContainer: DataController.shared.container)
  
  // MARK: - 조회 (Read)
  
  /// 모든 Routine의 ID를 가져옵니다.
  func fetchAllRoutineIDs() -> [PersistentIdentifier] {
    let descriptor = FetchDescriptor<Routine>()
    let routines = (try? modelContext.fetch(descriptor)) ?? []
    return routines.map { $0.persistentModelID }
  }

  /// 특정 날짜에 활성화된 Routine의 ID 목록을 가져옵니다.
  func fetchRoutineIDs(for date: Date) -> [PersistentIdentifier] {
    let predicate = #Predicate<Routine> { $0.startDate <= date }
    let descriptor = FetchDescriptor<Routine>(predicate: predicate)
    let routines = (try? modelContext.fetch(descriptor)) ?? []
    return routines.map { $0.persistentModelID }
  }

  // MARK: - 생성 (Create)
  
  /// 필요한 데이터를 받아 새로운 Routine 객체를 생성하고 DB에 추가합니다.
  func createRoutine(
    type: Int,
    displayName: String,
    desc: String?,
    category: String?,
    cycleType: Int,
    cycleValue: String,
    startDate: Date,
    memo: String?,
    usage: [String],
    precautions: [String],
    routineTimes: [RoutineTime],
    recommendedRoutineTimes: [RoutineTime]
  ) throws -> PersistentIdentifier {
    let newRoutine = Routine(
      type: type,
      displayName: displayName,
      desc: desc,
      category: category,
      cycleType: cycleType,
      cycleValue: cycleValue,
      startDate: startDate,
      memo: memo,
      usage: usage,
      precautions: precautions,
      routineTimes: routineTimes,
      recommendedRoutineTimes: recommendedRoutineTimes
    )
    modelContext.insert(newRoutine)
    try modelContext.save()
    return newRoutine.persistentModelID
  }
  
  /// 새로운 RoutineTime 객체를 생성하여 특정 Routine에 추가합니다.
  func createRoutineTime(time: Date, pillsPerDose: Int, forRoutineID routineID: PersistentIdentifier) {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return }
    
    let newRoutineTime = RoutineTime(time: time, pillsPerDose: pillsPerDose, routine: routine)
    modelContext.insert(newRoutineTime)
    try? modelContext.save()
  }

  /// 새로운 RoutineRecord 객체를 생성하여 특정 Routine에 추가합니다.
  func createRoutineRecord(forRoutineID routineID: PersistentIdentifier, timestamp: Date = Date()) {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return }
    
    let newRecord = RoutineRecord(timestamp: timestamp, routine: routine)
    modelContext.insert(newRecord)
    try? modelContext.save()
  }
  
  // MARK: - 삭제 (Delete)
  
  /// ID를 사용해 Routine 하나를 삭제합니다.
  func deleteRoutine(id: PersistentIdentifier) {
    guard let routine = modelContext.model(for: id) as? Routine else { return }
    modelContext.delete(routine)
    try? modelContext.save()
  }

  /// 모든 Routine을 삭제합니다.
  func deleteAllRoutines() {
    // iOS 18 / SwiftData 12 이상에서는 `try? modelContext.delete(model: Routine.self)` 한 줄로 가능
    let allRoutineIDs = fetchAllRoutineIDs()
    for id in allRoutineIDs {
      deleteRoutine(id: id)
    }
  }
}
