import XCTest
import SwiftData
@testable import Meditory

final class MealModelConversionTest: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var store: MealStore!
  
  override func setUpWithError() throws {
    let schema = Schema([Meal.self, Food.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    container = try ModelContainer(for: schema, configurations: [config])
    context = ModelContext(container)
    store = MealStore()
  }
  
  override func tearDownWithError() throws {
    container = nil
    context = nil
    store = nil
  }
  
  @MainActor
  func testMealInfoSaveAndFetch() throws {
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
    let mealEntity = Meal(model: originalMealInfo)
    store.addMeal(mealEntity, context: context)
    
    do {
      try context.save()
    } catch {
      XCTFail("Save failed: \(error)")
    }
    
    // Then
    let fetchedEntities = store.fetchAllMeals(context: context)
    XCTAssertEqual(fetchedEntities.count, 1)
    
    guard let firstEntity = fetchedEntities.first else {
      return XCTFail("No meal fetched")
    }
    
    let fetchedMealInfo = MealInfo(entity: firstEntity)
    
    XCTAssertEqual(fetchedMealInfo.name, originalMealInfo.name)
    XCTAssertEqual(fetchedMealInfo.foods.count, originalMealInfo.foods.count)
    XCTAssertEqual(fetchedMealInfo.date, originalMealInfo.date)
    
    // 총 영양소 합산 비교
    let originalMacros = originalMealInfo.foods.reduce(MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)) {
      MacroNutrients(
        carbohydrate: $0.carbohydrate + $1.macros.carbohydrate,
        protein: $0.protein + $1.macros.protein,
        fat: $0.fat + $1.macros.fat
      )
    }
    let fetchedMacros = fetchedMealInfo.foods.reduce(MacroNutrients(carbohydrate: 0, protein: 0, fat: 0)) {
      MacroNutrients(
        carbohydrate: $0.carbohydrate + $1.macros.carbohydrate,
        protein: $0.protein + $1.macros.protein,
        fat: $0.fat + $1.macros.fat
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
