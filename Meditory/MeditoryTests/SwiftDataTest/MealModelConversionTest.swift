import XCTest
import SwiftData
@testable import Meditory

final class MealModelConversionTest: XCTestCase {
  var container: ModelContainer!
  var context: ModelContext!
  var store: MealStore!
  
  override func setUpWithError() throws {
    // 메모리 전용 컨테이너 (테스트 간 오염 방지)
    let schema = Schema([Meal.self, Food.self, Macro.self])
    // isStoredInMemoryOnly 만 명시 (버전별 시그니처 차이 방지)
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
  
  /// MealModel 저장 → 불러오기 → 변환 테스트
  /*
  // TODO: 🚀 빌드 에러나는 테스트 코드 수정 후 재활성화
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
      date: Date(timeIntervalSince1970: 1_727_000_000), // 고정 날짜로 결정성 확보
      carbohydrate: food1.carbohydrate + food2.carbohydrate,
      protein: food1.protein + food2.protein,
      fat: food1.fat + food2.fat,
      foods: [food1, food2]
    )
    
    // When
    let mealEntity = Meal(model: originalMealModel)
    store.addMeal(mealEntity, context: context)
    
    // 저장 동기화 (타이밍 이슈 제거)
    do { try context.save() } catch {
      XCTFail("Save failed: \(error)")
    }
    
    // Then
    let fetchedEntities = store.fetchAllMeals(context: context)
    XCTAssertEqual(fetchedEntities.count, 1)
    
    guard let first = fetchedEntities.first else {
      return XCTFail("No meal fetched")
    }
    
    let fetchedMealModel = MealModel(entity: first)
    
    // Meal 단위 비교
    XCTAssertEqual(fetchedMealModel.mealName, originalMealModel.mealName)
    XCTAssertEqual(fetchedMealModel.carbohydrate, originalMealModel.carbohydrate, accuracy: 0.001)
    XCTAssertEqual(fetchedMealModel.protein, originalMealModel.protein, accuracy: 0.001)
    XCTAssertEqual(fetchedMealModel.fat, originalMealModel.fat, accuracy: 0.001)
    
    // Food 배열 비교를 '이름' 기준으로 정렬 후 zip
    let sortedFetchedFoods = fetchedMealModel.foods.sorted { $0.foodName < $1.foodName }
    let sortedOriginalFoods = originalMealModel.foods.sorted { $0.foodName < $1.foodName }
    
    XCTAssertEqual(sortedFetchedFoods.count, sortedOriginalFoods.count)
    
    for index in 0..<sortedOriginalFoods.count {
      let fetchedFood = sortedFetchedFoods[index]   // DB에서 꺼낸 데이터
      let originalFood = sortedOriginalFoods[index] // 기대하는 데이터
      
      XCTAssertEqual(fetchedFood.foodName, originalFood.foodName)
      XCTAssertEqual(fetchedFood.totalGram, originalFood.totalGram, accuracy: 0.001)
      
      XCTAssertEqual(fetchedFood.carbohydrateModel.macroType, .carbohydrate)
      XCTAssertEqual(fetchedFood.carbohydrateModel.gram, originalFood.carbohydrate, accuracy: 0.001)
      
      XCTAssertEqual(fetchedFood.proteinModel.macroType, .protein)
      XCTAssertEqual(fetchedFood.proteinModel.gram, originalFood.protein, accuracy: 0.001)
      
      XCTAssertEqual(fetchedFood.fatModel.macroType, .fat)
      XCTAssertEqual(fetchedFood.fatModel.gram, originalFood.fat, accuracy: 0.001)
    }
  }
   */
}
