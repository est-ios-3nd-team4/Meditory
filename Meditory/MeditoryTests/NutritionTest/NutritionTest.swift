//
//  NutritionTest.swift
//  MeditoryTests
//
//  Created by 이치훈 on 8/29/25.
//

import XCTest
import SwiftData
@testable import Meditory

final class NutritionTest: XCTestCase {
  
  var sut: NutritionMainViewModel!
  var testContainer: ModelContainer!
  
  override func setUp() {
    super.setUp()
    
    let schema = Schema([
      Meal.self,
      Food.self,
      User.self
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema,
                                                isStoredInMemoryOnly: true)
    
    do {
      testContainer = try ModelContainer(for: schema,
                                         configurations: [modelConfiguration])
    } catch {
      XCTFail("Failed to create test container: \(error)")
    }
  }
  
  override func tearDown() {
    sut = nil
    testContainer = nil
    super.tearDown()
  }
  
  @MainActor
  func testMacroRatio_withNormalIntakeAndRecommendation_returnsCorrectRatio() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 300,
                                             protein: 60,
                                             fat: 50)
    
    let foodInfo1 = FoodInfo(
      id: UUID(),
      name: "밥",
      weight: 100,
      macros: MacroNutrients(carbohydrate: 150,
                             protein: 30,
                             fat: 25)
    )
    
    let foodInfo2 = FoodInfo(
      id: UUID(),
      name: "닭가슴살",
      weight: 100,
      macros: MacroNutrients(carbohydrate: 75,
                             protein: 15,
                             fat: 12.5)
    )
    
    let mealInfo = MealInfo(
      id: UUID(),
      name: "점심",
      date: Date(),
      foods: [foodInfo1, foodInfo2]
    )
    
    sut.meals = [mealInfo]
    
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 0.75, accuracy: 0.001)
    XCTAssertEqual(ratio.protein, 0.75, accuracy: 0.001)
    XCTAssertEqual(ratio.fat, 0.75, accuracy: 0.001)
  }
  
  @MainActor
  func testMacroRatio_withZeroIntake_returnZeroRatio() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 300,
                                             protein: 60,
                                             fat: 50)
    sut.meals = []
    
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 0.0, accuracy: 0.001)
    XCTAssertEqual(ratio.protein, 0.0, accuracy: 0.001)
    XCTAssertEqual(ratio.fat, 0.0, accuracy: 0.001)
  }
  
  @MainActor
  func testMacroRatio_withRecommendation_returnZeroRatio() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 0,
                                             protein: 0,
                                             fat: 0)
    
    let foodInfo = FoodInfo(
      id: UUID(),
      name: "테스트 음식",
      weight: 100,
      macros: MacroNutrients(carbohydrate: 100, protein: 50, fat: 25)
    )
    
    let mealInfo = MealInfo(
      id: UUID(),
      name: "테스트 식사",
      date: Date(),
      foods: [foodInfo]
    )
    
    sut.meals = [mealInfo]
    
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 0.0, accuracy: 0.001)
    XCTAssertEqual(ratio.protein, 0.0, accuracy: 0.001)
    XCTAssertEqual(ratio.fat, 0.0, accuracy: 0.001)
  }
  
  @MainActor
  func testMacroRatios_withExcessiveIntake_returnsRatioAboveOnr() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 100,
                                             protein: 50,
                                             fat: 30)
    
    let foodInfo = FoodInfo(
      id: UUID(),
      name: "고칼로리 음식",
      weight: 200,
      macros: MacroNutrients(carbohydrate: 200,
                             protein: 100,
                             fat: 60)
    )
    
    let mealInfo = MealInfo(
      id: UUID(),
      name: "과식",
      date: Date(),
      foods: [foodInfo]
    )
    
    sut.meals = [mealInfo]
    
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 2.0, accuracy: 0.001)
    XCTAssertEqual(ratio.protein, 2.0, accuracy: 0.001)
    XCTAssertEqual(ratio.fat, 2.0, accuracy: 0.001)
  }
  
  @MainActor
  func testMacroRatio_withMultipleMealsAndMixedIntake_calculatesCorrectTotalRatio() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 100, protein: 50, fat: 30)
    
    let foodInfo = FoodInfo(
      id: UUID(),
      name: "고칼로리 음식",
      weight: 200,
      macros: MacroNutrients(carbohydrate: 200, protein: 100, fat: 60)
    )
    
    let mealInfo = MealInfo(
      id: UUID(),
      name: "과식",
      date: Date(),
      foods: [foodInfo]
    )
    
    sut.meals = [mealInfo]
    
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 2.0, accuracy: 0.001)
    XCTAssertEqual(ratio.protein, 2.0, accuracy: 0.001)
    XCTAssertEqual(ratio.fat, 2.0, accuracy: 0.001)
  }
  
  @MainActor
  func testMacroPercent_withNormalRatio_returnsCorrectPercentage() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 200, protein: 100, fat: 50)
    
    let foodInfo = FoodInfo(
      id: UUID(),
      name: "테스트 음식",
      weight: 100,
      macros: MacroNutrients(carbohydrate: 100, protein: 50, fat: 25)
    )
    
    let mealInfo = MealInfo(
      id: UUID(),
      name: "테스트 식사",
      date: Date(),
      foods: [foodInfo]
    )
    
    sut.meals = [mealInfo]
    
    // act
    let percent = sut.macroPercent
    
    // assert
    // 비율: 100/200=0.5, 50/100=0.5, 25/50=0.5
    // 퍼센트: 0.5 * 100 = 50%
    XCTAssertEqual(percent.carbohydrate, 50.0, accuracy: 0.001)
    XCTAssertEqual(percent.protein, 50.0, accuracy: 0.001)
    XCTAssertEqual(percent.fat, 50.0, accuracy: 0.001)
  }
  
}
