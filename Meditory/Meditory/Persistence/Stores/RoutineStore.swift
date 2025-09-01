import Foundation
import SwiftData

/// `Routine` 관련 SwiftData 작업을 처리하는 ModelActor임.
///
/// 이 액터는 앱의 데이터베이스 컨텍스트에서 루틴 데이터의 생성, 조회, 수정, 삭제 작업을 스레드에 안전하게 관리함.
@ModelActor
actor RoutineStore {
  /// 앱 전역에서 접근 가능한 공유 싱글턴 인스턴스임.
  static let shared = RoutineStore(modelContainer: DataController.shared.container)
  
  // MARK: - 조회 (Read)
  
  /// 데이터베이스에 저장된 모든 `Routine`의 ID 목록을 조회함.
  /// - Returns: `PersistentIdentifier`의 배열.
  func fetchAllRoutineIDs() -> [PersistentIdentifier] {
    let descriptor = FetchDescriptor<Routine>()
    let routines = (try? modelContext.fetch(descriptor)) ?? []
    return routines.map { $0.persistentModelID }
  }
  
  /// 특정 날짜를 기준으로 활성화된 `Routine`의 ID 목록을 조회함.
  ///
  /// 루틴의 시작 날짜(`startDate`)가 조회하려는 날짜보다 이르거나 같은 모든 루틴을 반환함.
  /// - Parameter date: 조회 기준이 되는 날짜.
  /// - Returns: 조건을 만족하는 `Routine`의 `PersistentIdentifier` 배열.
  func fetchRoutineIDs(for date: Date) -> [PersistentIdentifier] {
    let predicate = #Predicate<Routine> { $0.startDate <= date }
    let descriptor = FetchDescriptor<Routine>(predicate: predicate)
    let routines = (try? modelContext.fetch(descriptor)) ?? []
    return routines.map { $0.persistentModelID }
  }
  
  /// 데이터베이스에 저장된 모든 `Routine` 객체 전체를 조회함.
  /// - Returns: `Routine` 객체의 배열.
  func fetchAllRoutines() -> [Routine] {
    let descriptor = FetchDescriptor<Routine>()
    let routines = (try? modelContext.fetch(descriptor)) ?? []
    return routines.map { $0 }
  }
  
  // MARK: - 생성 (Create)
  
  /// 새로운 `Routine` 객체를 생성하고 데이터베이스에 저장함.
  /// - Parameters:
  ///   - type: 루틴 타입.
  ///   - displayName: 화면에 표시될 루틴 이름.
  ///   - desc: 루틴에 대한 설명.
  ///   - category: 루틴 카테고리.
  ///   - cycleType: 반복 주기 타입.
  ///   - cycleValue: 반복 주기 값.
  ///   - startDate: 루틴 시작 날짜.
  ///   - memo: 사용자 메모.
  ///   - usage: 용법 정보 배열.
  ///   - precautions: 주의사항 정보 배열.
  ///   - routineTimes: 복용 시간 정보 배열.
  ///   - recommendedRoutineTimes: 권장 복용 시간 정보 배열.
  /// - Throws: `modelContext.save()` 과정에서 발생할 수 있는 오류를 전달함.
  /// - Returns: 새로 생성된 `Routine` 객체의 영구 식별자(`PersistentIdentifier`).
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
  
  /// 새로운 `RoutineTime` 객체를 생성하여 특정 `Routine`에 추가하고 저장함.
  /// - Parameters:
  ///   - time: 복용 시간.
  ///   - pillsPerDose: 1회 복용량.
  ///   - routineID: `RoutineTime`을 추가할 대상 `Routine`의 ID.
  func createRoutineTime(time: Date, pillsPerDose: Int, forRoutineID routineID: PersistentIdentifier) {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return }
    
    let newRoutineTime = RoutineTime(time: time, pillsPerDose: pillsPerDose, routine: routine)
    routine.routineTimes.append(newRoutineTime)
    modelContext.insert(newRoutineTime)
    try? modelContext.save()
  }
  
  /// 특정 루틴에 대한 새로운 수행 기록(`RoutineRecord`)을 생성하고 저장함.
  /// - Parameters:
  ///   - routineID: 기록을 추가할 `Routine`의 ID.
  ///   - timestamp: 기록 시점. 기본값은 현재 시간임.
  func createRoutineRecord(forRoutineID routineID: PersistentIdentifier, timestamp: Date = Date()) {
    guard let routine = modelContext.model(for: routineID) as? Routine else { return }
    
    let newRecord = RoutineRecord(timestamp: timestamp, routine: routine)
    modelContext.insert(newRecord)
    try? modelContext.save()
  }
  
  // MARK: - 수정 (Update)
  
  /// 기존 `Routine` 객체의 정보를 수정하고 데이터베이스에 저장함.
  /// - Parameters:
  ///   - routine: 수정할 `Routine` 객체.
  ///   - type: 루틴 타입.
  ///   - displayName: 화면에 표시될 루틴 이름.
  ///   - desc: 루틴에 대한 설명.
  ///   - category: 루틴 카테고리.
  ///   - cycleType: 반복 주기 타입.
  ///   - cycleValue: 반복 주기 값.
  ///   - startDate: 루틴 시작 날짜.
  ///   - memo: 사용자 메모.
  ///   - usage: 용법 정보 배열.
  ///   - precautions: 주의사항 정보 배열.
  ///   - routineTimes: 복용 시간 정보 배열.
  ///   - recommendedRoutineTimes: 권장 복용 시간 정보 배열.
  /// - Throws: `modelContext.save()` 과정에서 발생할 수 있는 오류를 전달함.
  func updateRoutine(
    routine: Routine,
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
  ) throws {
    routine.type = type
    routine.displayName = displayName
    routine.desc = desc
    routine.category = category
    routine.cycleType = cycleType
    routine.cycleValue = cycleValue
    routine.startDate = startDate
    routine.memo = memo
    routine.usage = usage
    routine.precautions = precautions
    routine.routineTimes = routineTimes
    routine.recommendedRoutineTimes = recommendedRoutineTimes
    
    try modelContext.save()
  }
  
  // MARK: - 삭제 (Delete)
  
  /// 주어진 ID를 사용하여 특정 `Routine` 객체를 데이터베이스에서 삭제함.
  /// - Parameter id: 삭제할 `Routine`의 `PersistentIdentifier`.
  func deleteRoutine(id: PersistentIdentifier) {
    guard let routine = modelContext.model(for: id) as? Routine else { return }
    modelContext.delete(routine)
    try? modelContext.save()
  }
  
  /// 데이터베이스에 저장된 모든 `Routine` 객체를 삭제함.
  func deleteAllRoutines() {
    // iOS 18 / SwiftData 12 이상에서는 `try? modelContext.delete(model: Routine.self)` 한 줄로 가능
    let allRoutineIDs = fetchAllRoutineIDs()
    for id in allRoutineIDs {
      deleteRoutine(id: id)
    }
  }
}
