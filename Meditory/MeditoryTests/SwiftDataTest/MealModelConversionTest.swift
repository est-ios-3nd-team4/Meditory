import XCTest
import SwiftData
@testable import Meditory

final class MealModelConversionTest: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var store: MealStore!
  
  // 테스트 설정도 비동기 작업을 포함하므로 async로 변경합니다.
  override func setUp() async throws {
    let schema = Schema([Meal.self, Food.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    // MealStore도 ModelContainer를 사용해 초기화합니다.
    store = MealStore(modelContainer: container)
  }
  
  override func tearDownWithError() throws {
    container = nil
    context = nil
    store = nil
  }
  
  func testMealInfoSaveAndFetch() async throws {
    // Given
    let food1 = FoodInfo(
      id: UUID(),
      name: "닭가슴살",
      weight: 100,
      macros: MacroNutrients(carbohydrate: 0, protein: 23, fat: 1.2)
    )
    let food2 = FoodInfo(
      id: UUID(),
      name: "밥",
      weight: 200,
      macros: MacroNutrients(carbohydrate: 72, protein: 5, fat: 0.4)
    )
    
    let originalMealInfo = MealInfo(
      id: UUID(),
      name: "점심",
      date: Date(timeIntervalSince1970: 1_727_000_000),
      foods: [food1, food2]
    )
    
    // When
    // 새로운 createMeal 메서드를 사용합니다.
    let mealID = try await store.createMeal(
      id: originalMealInfo.id,
      mealName: originalMealInfo.name,
      date: originalMealInfo.date,
      foods: originalMealInfo.foods.map { Food(from: $0) }
    )
    
    // Then
    // 새로운 fetchAllMealIDs 메서드를 사용합니다.
    let fetchedIDs = await store.fetchAllMealIDs()
    XCTAssertEqual(fetchedIDs.count, 1)
    
    let firstID = try XCTUnwrap(fetchedIDs.first)
    XCTAssertEqual(firstID, mealID)
    
    guard let firstEntity = context.model(for: firstID) as? Meal else {
      return XCTFail("No meal fetched")
    }
    
    let fetchedMealInfo = MealInfo(entity: firstEntity)
    
    XCTAssertEqual(fetchedMealInfo.name, originalMealInfo.name)
    XCTAssertEqual(fetchedMealInfo.foods.count, originalMealInfo.foods.count)
    XCTAssertEqual(fetchedMealInfo.date, originalMealInfo.date)
    
    // 총 영양소 합산 비교
    let originalMacros = originalMealInfo.foods.reduce(MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)) { acc, foodInfo in
      MacroNutrients(
        carbohydrate: acc.carbohydrate + foodInfo.macros.carbohydrate,
        protein: acc.protein + foodInfo.macros.protein,
        fat: acc.fat + foodInfo.macros.fat
      )
    }
    let fetchedMacros = fetchedMealInfo.foods.reduce(MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)) { acc, foodInfo in
      MacroNutrients(
        carbohydrate: acc.carbohydrate + foodInfo.macros.carbohydrate,
        protein: acc.protein + foodInfo.macros.protein,
        fat: acc.fat + foodInfo.macros.fat
      )
    }
    
    XCTAssertEqual(fetchedMacros.carbohydrate, originalMacros.carbohydrate, accuracy: 0.001)
    XCTAssertEqual(fetchedMacros.protein, originalMacros.protein, accuracy: 0.001)
    XCTAssertEqual(fetchedMacros.fat, originalMacros.fat, accuracy: 0.001)
    
    // 음식별 비교 (이름 기준 정렬)
    let sortedOriginalFoods = originalMealInfo.foods.sorted { $0.name < $1.name }
    let sortedFetchedFoods = fetchedMealInfo.foods.sorted { $0.name < $1.name }
    XCTAssertEqual(sortedOriginalFoods.count, sortedFetchedFoods.count)
    
    for index in 0..<sortedOriginalFoods.count {
      let original = sortedOriginalFoods[index]
      let fetched = sortedFetchedFoods[index]
      
      XCTAssertEqual(fetched.name, original.name)
      XCTAssertEqual(fetched.weight, original.weight, accuracy: 0.001)
      XCTAssertEqual(fetched.macros.carbohydrate, original.macros.carbohydrate, accuracy: 0.001)
      XCTAssertEqual(fetched.macros.protein, original.macros.protein, accuracy: 0.001)
      XCTAssertEqual(fetched.macros.fat, original.macros.fat, accuracy: 0.001)
    }
  }
}
