import Foundation
import SwiftData

@ModelActor
actor MealStore {
  // 앱 전역에서 접근할 수 있는 싱글턴 인스턴스
  static let shared = MealStore(modelContainer: DataController.shared.container)
  
  // MARK: - 생성 (Create)

  /// Meal 1개를 생성하고 저장합니다.
  /// - Parameters:
  ///   - mealName: 식사 이름 (예: "아침", "점심")
  ///   - date: 식사 날짜
  ///   - foods: 식사에 포함된 [Food] 객체 배열
  func createMeal(id: UUID, mealName: String, date: Date, foods: [Food]) throws -> PersistentIdentifier {
    let newMeal = Meal(id: id,mealName: mealName, date: date, foods: foods)
    modelContext.insert(newMeal)
    try modelContext.save()
    return newMeal.persistentModelID
  }
  
  // MARK: - 조회 (Read)

  /// 모든 Meal의 ID 목록을 날짜 기준으로 정렬하여 조회합니다.
  func fetchAllMealIDs() -> [PersistentIdentifier] {
    // date 프로퍼티 기준 오름차순 정렬
    let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.date)])
    let meals = (try? modelContext.fetch(descriptor)) ?? []
    return meals.map { $0.persistentModelID }
  }
  
  // MARK: - 삭제 (Delete)

  /// ID를 사용해 특정 Meal 1개를 삭제합니다.
  func deleteMeal(id: PersistentIdentifier) {
    guard let meal = modelContext.model(for: id) as? Meal else { return }
    modelContext.delete(meal)
    try? modelContext.save()
  }
  
  /// 모든 Meal을 삭제합니다.
  func deleteAllMeals() {
    let allMealIDs = fetchAllMealIDs()
    for id in allMealIDs {
      deleteMeal(id: id)
    }
  }
}
