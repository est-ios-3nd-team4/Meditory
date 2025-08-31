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
  
  @MainActor
  func testMacroRatio_withNormalIntakeAndRecommendation_returnsCorrectRatio() async {
    // arrange
    let context = testContainer.mainContext
    sut = NutritionMainViewModel(modelContext: context)
    
    sut.recommendedCalories = MacroNutrients(carbohydrate: 300,
                                             protein: 60,
                                             fat: 50)
    // act
    let ratio = sut.macroRatio
    
    // assert
    XCTAssertEqual(ratio.carbohydrate, 0, accuracy: 0.001)
  }

}
