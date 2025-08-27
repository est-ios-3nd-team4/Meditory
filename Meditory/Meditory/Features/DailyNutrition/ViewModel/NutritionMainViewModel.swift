//
//  NutritionMainViewModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/18/25.
//

import SwiftUI
import SwiftData

@MainActor
class NutritionMainViewModel: ObservableObject {
  
  // MARK: - Published Properties
  /// meals: swiftDat에서 meal 데이터를 불러 올 때 selectredDate를 기반으로 filter해서 불러옴
  @Published var meals: [MealInfo] = []
  @Published var selectedDate = Date()
  @Published var selectedMeal: MealInfo? = nil
  @Published var healthKitManager = HealthKitManager()
  
  // SwiftData
  //  @Environment(\.modelContext) private var modelContext
  private let modelContext: ModelContext
  
  // SwiftData - User
  @Published var currentUser: User?
  @Published var userHeight: Double?
  @Published var userWeight: Double?
  @Published var userAge: Int = 0
  @Published var userGender: String = ""
  @Published var recommendedCalories = MacroNutrients(carbohydrate: 0,
                                                      protein: 0,
                                                      fat: 0) // 권장 Macro
  
  var foodList: [FoodInfo] { meals.flatMap { $0.foods } }
  var macroPercent: MacroNutrients {
    let totalMacros = foodList.reduce(into: MacroNutrients(carbohydrate: 0,
                                                           protein: 0,
                                                           fat: 0)) { result, food in
      result.carbohydrate += food.macros.carbohydrate
      result.protein += food.macros.protein
      result.fat += food.macros.fat
    }
    
    return MacroNutrients(carbohydrate: totalMacros.carbohydrate / recommendedCalories.carbohydrate,
                          protein: totalMacros.protein / recommendedCalories.protein,
                          fat: totalMacros.fat / recommendedCalories.fat)
  }
  
  
  
  // TODO: SwiftData 쿼리문으로 처리 예정
  //  var todayMeals: [MealInfo] {
  //    meals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectredDate) }
  //  }
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    
    
    
    Task {
      if healthKitManager.checkCurrentAuthorizationStatus() {
        await healthKitManager.loadTodaySteps()
      }
      
      await loadUserData() // 사용자 데이터 load
    }
  }
  
  func requestHealthKitPermission() async {
    do {
      // 이미 권한이 있는지 먼저 확인
      if healthKitManager.checkCurrentAuthorizationStatus() {
        print("✅ 이미 HealthKit 권한이 허용됨")
        await healthKitManager.loadTodaySteps()
        updateRecommendedCalories()
        return
      }
      
      // 권한 요청
      try await healthKitManager.requestAuthorization() // error
      print("✅ HealthKit 권한 요청 성공")
      
      // 걸음 수 데이터 로드
      await healthKitManager.loadTodaySteps()
      
      // 권장 칼로리 업데이트
      updateRecommendedCalories()
      
    } catch {
      print("❌ HealthKit 권한 요청 실패: \(error)")
      // 권한이 없어도 기본값으로 권장 칼로리 계산
      updateRecommendedCalories()
    }
  }
  
  private func updateRecommendedCalories() {
    guard let weight = userWeight,
          let height = userHeight else {
      print("⚠️ 사용자 신체 정보가 없어서 권장 칼로리 계산 불가")
      return
    }
    
    let isMale = (userGender == "male")
    recommendedCalories = getMacroGuide(weight: weight,
                                        height: height,
                                        age: userAge,
                                        isMale: isMale)
    
    print("📊 권장 칼로리 업데이트 완료: \(recommendedCalories)")
  }
  
  /// 오늘 하루 Macro의 총 합을 제공하는 연산 프로퍼티
  var todayTotalMacros: MacroNutrients {
    meals.reduce(MacroNutrients(carbohydrate: 0,
                                protein: 0,
                                fat: 0)) { result, macro in
      MacroNutrients(carbohydrate: result.carbohydrate + macro.macros.carbohydrate,
                     protein: result.protein + macro.macros.protein,
                     fat: result.fat + macro.macros.fat)
    }
  }
  
  func selectedMeal(_ meal: MealInfo) {
    self.selectedMeal = meal
  }
  
  func deSelectedMeal() {
    self.selectedMeal = nil
  }
  
}

// MARK: RecommendedMacroCalculator
extension NutritionMainViewModel {
  func getMacroGuide(weight: Double, height: Double, age: Int, isMale: Bool) -> MacroNutrients {
    let activityLevel = healthKitManager.getActivityLevel()
    
    let bmr = RecommendedMacroCalculator.calculateBMR(weight: weight, height: height, age: age, isMale: isMale)
    
    let calories = RecommendedMacroCalculator.calculateDailyCalories(bmr: bmr, activityLevel: activityLevel)
    
    return RecommendedMacroCalculator.calculateMacros(dailyCalories: calories)
  }
}

// MARK: - SwiftData-User
extension NutritionMainViewModel {
  func loadUserData() async {
    
    do {
      await UserStore.shared.loadUser()
      let user = try await UserStore.shared.currentUser()
      
      // 사용자 정보 설정
      await MainActor.run {
        self.currentUser = user
        self.userHeight = user.currentHeight
        self.userWeight = user.currentWeight
        self.userAge = user.age
        self.userGender = user.gender
        
        self.recommendedCalories = getMacroGuide(weight: userWeight ?? 60,
                                                 height: userHeight ?? 170,
                                                 age: userAge,
                                                 isMale: userGender == "male" ? true : false)
      }
      
    } catch {
      print("사용자 데이터 로드 실패: \(error)")
    }
  }
  
}

// MARK: - SwiftData-Meal&Food
extension NutritionMainViewModel {
  
  func registerFood(name: String, macros: MacroNutrients) {
    guard !name.isEmpty else {
      print("음식 이름이 비어있습니다")
      return
    }
    
    let foodInfo = FoodInfo(
      id: UUID(),
      name: name,
      weight: 0.0,
      macros: macros)
    
    let food = foodInfo.toFood()
    
    // selectedMeal이 있으면 해당 meal에 추가, 없으면 새로운 meal
    if let selectedMeal = selectedMeal {
      updateMealWithFood(mealId: selectedMeal.id, food: food)
    } else {
      createNewMealWithFood(food: food)
    }
  }
  
  private func updateMealWithFood(mealId: UUID, food: Food) {
    do {
      let descriptor = FetchDescriptor<Meal>(predicate: #Predicate { meal in
        meal.id == mealId
      })
      
      guard let existingMeal = try modelContext.fetch(descriptor).first else {
        print("Meal을 찾을 수 없습니다")
        createNewMealWithFood(food: food)
        return
      }
      
      existingMeal.foods.append(food)
      modelContext.insert(food)
      
      try modelContext.save()
      
      if let index = meals.firstIndex(where: { $0.id == mealId }) {
        meals[index].foods.append(FoodInfo(id: food.id,
                                          name: food.foodName,
                                          weight: food.totalGram,
                                          macros: MacroNutrients(carbohydrate: food.carbohydrate,
                                                                 protein: food.protein,
                                                                 fat: food.fat)))
      }
      
      print("✅ 음식이 기존 식단에 추가되었습니다")
    } catch {
      print("❌ Meal 업데이트 실패: \(error)")
    }
  }

  private func createNewMealWithFood(food: Food) {
    do {
      let newMeal = Meal(id: UUID(),
                         mealName: "",
                         date: selectedDate,
                         foods: [food])
      
      modelContext.insert(newMeal)
      modelContext.insert(food)
      try modelContext.save()
      
      let mealInfo = MealInfo(id: newMeal.id,
                              name: newMeal.mealName,
                              date: newMeal.date,
                              foods: [FoodInfo(id: food.id,
                                               name: food.foodName,
                                               weight: food.totalGram,
                                               macros: MacroNutrients(carbohydrate: food.carbohydrate,
                                                                      protein: food.protein,
                                                                      fat: food.fat))])
      
      meals.append(mealInfo)
      selectedMeal = mealInfo
      
      print("✅ 새 식단이 생성되었습니다")
    } catch {
      print("❌ Meal 생성 실패: \(error)")
    }
  }
  
  func loadMealsForDate(_ date: Date) async {
    do {
      let calendar = Calendar.current
      let startOfDay = calendar.startOfDay(for: date)
      let endOfDay = calendar.date(byAdding: .day,
                                   value: 1,
                                   to: startOfDay)!
      
      let descriptor = FetchDescriptor<Meal>(
        predicate: #Predicate { meal in
          meal.date >= startOfDay && meal.date < endOfDay
        },
        sortBy: [SortDescriptor(\.date)]
      )
      
      let fetchedMeals = try modelContext.fetch(descriptor)
      
      await MainActor.run {
        self.meals = fetchedMeals.map { meal in
          MealInfo(id: meal.id,
                   name: meal.mealName,
                   date: meal.date,
                   foods: meal.foods.map { food in
            FoodInfo(id: food.id,
                     name: food.foodName,
                     weight: food.totalGram,
                     macros: MacroNutrients(carbohydrate: food.carbohydrate,
                                            protein: food.protein,
                                            fat: food.fat))
            
          })
        }
      }
    } catch {
      print("❌ Meals 로드 실패: \(error)")
    }
  }
  
  // MARK: SwiftDataLoad
  func loadMealForSelectedDate() async {
    await loadMealsForDate(selectedDate)
  }
  
//   // test
//  func testDataOperations() {
//          print("=== SwiftData 테스트 시작 ===")
//          
//          // 1. 테스트 데이터 추가
//          let testMacros = MacroNutrients(carbohydrate: 30, protein: 20, fat: 10)
//          registerFood(name: "테스트 음식", macros: testMacros)
//          print("테스트 음식 추가 완료")
//          
//          // 2. 현재 meals 상태 출력
//          print("현재 meals 개수: \(meals.count)")
//          
//          for (index, meal) in meals.enumerated() {
//              print("Meal \(index): ID=\(meal.id), 음식 개수=\(meal.foods.count)")
//              for food in meal.foods {
//                  print("  - \(food.name): 탄\(food.macros.carbohydrate)g, 단\(food.macros.protein)g, 지\(food.macros.fat)g")
//              }
//          }
//          
//          // 3. 데이터 다시 로드 테스트
//          Task {
//              await loadMealsForDate(selectedDate)
//              print("데이터 재로드 완료: \(meals.count)개 meals")
//          }
//          
//          print("=== SwiftData 테스트 완료 ===")
//      }
}

// MARK: - Network
extension NutritionMainViewModel {
  func request(mealName: String) async throws {
    print("✅ 요청", Date.now)
    
    let prompt = MealNutritionPrompt.makePrompt(mealName: mealName)
    
    let response = try await AlanAPIClient().request(content: prompt)
    
    print("✅ 응답", Date.now)
    
    let mealNutrition = try? JSONDecoder().decode(MealNutrition.self, from: Data(response.utf8))
    
    dump(mealNutrition)
  }
}
