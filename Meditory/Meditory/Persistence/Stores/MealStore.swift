import Foundation
import SwiftData

/// `Meal` 관련 SwiftData 작업을 처리하는 ModelActor임.
///
/// 이 액터는 앱의 데이터베이스 컨텍스트에서 식사 데이터의 생성, 조회, 삭제 작업을 안전하게 관리함.
@ModelActor
actor MealStore {
  /// 앱 전역에서 접근 가능한 공유 싱글턴 인스턴스임.
  static let shared = MealStore(modelContainer: DataController.shared.container)
  
  // MARK: - 생성 (Create)
  
  /// 새로운 `Meal` 객체를 생성하고 데이터베이스에 저장함.
  /// - Parameters:
  ///   - id: 생성할 식사의 고유 UUID.
  ///   - mealName: 식사 이름 (예: "아침", "점심").
  ///   - date: 식사 날짜.
  ///   - foods: 식사에 포함된 `Food` 객체의 배열.
  /// - Throws: `modelContext.save()` 과정에서 발생할 수 있는 오류를 전달함.
  /// - Returns: 새로 생성된 `Meal` 객체의 영구 식별자(`PersistentIdentifier`).
  func createMeal(id: UUID, mealName: String, date: Date, foods: [Food]) throws -> PersistentIdentifier {
    let newMeal = Meal(id: id,mealName: mealName, date: date, foods: foods)
    modelContext.insert(newMeal)
    try modelContext.save()
    return newMeal.persistentModelID
  }
  
  // MARK: - 조회 (Read)
  
  /// 데이터베이스에 저장된 모든 `Meal` 객체의 ID 목록을 조회함.
  /// - Returns: 날짜순으로 정렬된 `PersistentIdentifier` 배열.
  func fetchAllMealIDs() -> [PersistentIdentifier] {
    // date 프로퍼티 기준 오름차순 정렬
    let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.date)])
    let meals = (try? modelContext.fetch(descriptor)) ?? []
    return meals.map { $0.persistentModelID }
  }
  
  // MARK: - 삭제 (Delete)
  
  /// 주어진 ID를 사용하여 특정 `Meal` 객체를 데이터베이스에서 삭제함.
  /// - Parameter id: 삭제할 `Meal`의 `PersistentIdentifier`.
  func deleteMeal(id: PersistentIdentifier) {
    guard let meal = modelContext.model(for: id) as? Meal else { return }
    modelContext.delete(meal)
    try? modelContext.save()
  }
  
  /// 데이터베이스에 저장된 모든 `Meal` 객체를 삭제함.
  func deleteAllMeals() {
    let allMealIDs = fetchAllMealIDs()
    for id in allMealIDs {
      deleteMeal(id: id)
    }
  }
}
