import XCTest
import SwiftData
@testable import Meditory

final class MealModelConversionTest: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!
    var store: MealStore!

    override func setUpWithError() throws {
        let schema = Schema([Meal.self, Food.self, Macro.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // 메모리 DB
        container = try ModelContainer(for: schema, configurations: [config])
        context = ModelContext(container)
        store = MealStore()
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        store = nil
    }

    /// MealModel 저장 → 불러오기 → 변환 테스트
  @MainActor
  func testMealModelSaveAndFetch() throws {
      // Given
      let food1 = FoodModel(
          foodName: "닭가슴살",
          totalGram: 100,
          carbohydrate: 0,
          protein: 23,
          fat: 1.2
      )
      let food2 = FoodModel(
          foodName: "밥",
          totalGram: 200,
          carbohydrate: 72,
          protein: 5,
          fat: 0.4
      )

      let originalMealModel = MealModel(
          mealName: "점심",
          date: Date(),
          carbohydrate: food1.carbohydrate + food2.carbohydrate,
          protein: food1.protein + food2.protein,
          fat: food1.fat + food2.fat,
          foods: [food1, food2]
      )

      // When
      let mealEntity = Meal(model: originalMealModel)
      store.addMeal(mealEntity, context: context)

      // Then
      let fetchedEntities = store.fetchAllMeals(context: context)
      XCTAssertEqual(fetchedEntities.count, 1)

      let fetchedMealModel = MealModel(entity: fetchedEntities.first!)

      // Meal 단위 비교
      XCTAssertEqual(fetchedMealModel.mealName, originalMealModel.mealName)
      XCTAssertEqual(fetchedMealModel.carbohydrate, originalMealModel.carbohydrate, accuracy: 0.001)
      XCTAssertEqual(fetchedMealModel.protein, originalMealModel.protein, accuracy: 0.001)
      XCTAssertEqual(fetchedMealModel.fat, originalMealModel.fat, accuracy: 0.001)

      // Food 개수와 이름 비교
      XCTAssertEqual(fetchedMealModel.foods.count, originalMealModel.foods.count)
      for (fetchedFood, originalFood) in zip(fetchedMealModel.foods, originalMealModel.foods) {
          XCTAssertEqual(fetchedFood.foodName, originalFood.foodName)
          XCTAssertEqual(fetchedFood.totalGram, originalFood.totalGram, accuracy: 0.001)

          // Macro 값 비교 (탄/단/지)
          XCTAssertEqual(fetchedFood.carbohydrateModel.macroType, .carbohydrate)
          XCTAssertEqual(fetchedFood.carbohydrateModel.gram, originalFood.carbohydrate, accuracy: 0.001)

          XCTAssertEqual(fetchedFood.proteinModel.macroType, .protein)
          XCTAssertEqual(fetchedFood.proteinModel.gram, originalFood.protein, accuracy: 0.001)

          XCTAssertEqual(fetchedFood.fatModel.macroType, .fat)
          XCTAssertEqual(fetchedFood.fatModel.gram, originalFood.fat, accuracy: 0.001)
      }
  }

}
