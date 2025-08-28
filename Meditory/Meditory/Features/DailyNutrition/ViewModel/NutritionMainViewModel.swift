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
  
  func findMeal(for foodId: UUID) -> MealInfo? {
    return meals.first { meal in
      meal.foods.contains { $0.id == foodId }
    }
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
    print("func loadMealForSelectedDate() async called")
  }
  
}

// MARK: - ViewModel Extension for Food Management

extension NutritionMainViewModel {
  
  func updateFood(foodId: UUID, mealId: UUID, name: String, macros: MacroNutrients) {
    do {
      let foodDescriptor = FetchDescriptor<Food>(predicate: #Predicate { food in
        food.id == foodId
      })
      
      guard let existingFood = try modelContext.fetch(foodDescriptor).first else {
        print("❌ 음식을 찾을 수 없습니다")
        return
      }
      
      existingFood.foodName = name
      existingFood.carbohydrate = macros.carbohydrate
      existingFood.protein = macros.protein
      existingFood.fat = macros.fat
      
      try modelContext.save()
      
      if let mealIndex = meals.firstIndex(where: { $0.id == mealId }),
         let foodIndex = meals[mealIndex].foods.firstIndex(where: { $0.id == foodId }) {
        meals[mealIndex].foods[foodIndex] = FoodInfo(id: foodId,
                                                     name: name,
                                                     weight: existingFood.totalGram,
                                                     macros: macros)
      }
      
      print("✅ 음식이 성공적으로 업데이트되었습니다")
    } catch {
      print("❌ 음식 업데이트 실패: \(error)")
    }
  }
  
  func deleteFood(foodId: UUID, mealId: UUID) {
    do {
      let foodDescriptor = FetchDescriptor<Food>(predicate: #Predicate { food in
        food.id == foodId
      })
      
      guard let foodToDelete = try modelContext.fetch(foodDescriptor).first else {
        print("❌ 삭제할 음식을 찾을 수 없습니다")
        return
      }
      
      modelContext.delete(foodToDelete)
      try modelContext.save()
      
      if let mealIndex = meals.firstIndex(where: { $0.id == mealId }) {
        meals[mealIndex].foods.removeAll { $0.id == foodId }
        
        if meals[mealIndex].foods.isEmpty {
          let mealDescriptor = FetchDescriptor<Meal>(predicate: #Predicate { meal in
            meal.id == mealId
          })
          
          if let mealToDelete = try modelContext.fetch(mealDescriptor).first {
            modelContext.delete(mealToDelete)
            try modelContext.save()
          }
          
          meals.removeAll() { $0.id == mealId }
          
          if selectedMeal?.id == mealId {
            selectedMeal = nil
          }
        }
      }
      
      print("✅ 음식이 성공적으로 삭제되었습니다")
    } catch {
      print("❌ 음식 삭제 실패: \(error)")
    }
  }
  
}

// MARK: - Network
extension NutritionMainViewModel {
  func request(mealName: String) async throws -> FoodInfo {
    print("✅ 요청", Date.now)
    
    let prompt = MealNutritionPrompt.makePrompt(mealName: mealName)
    
    let response = try await AlanAPIClient().request(content: prompt)
    
    print("✅ 응답", Date.now)
    
    let mealNutrition = try? JSONDecoder().decode(MealNutrition.self, from: Data(response.utf8))
    
    let safeyMealNutrition = mealNutrition ?? MealNutrition(type: 1,
                                                   name: "알 수 없음",
                                                   carbohydrate: 0,
                                                   protein: 0,
                                                   fat: 0)
    dump(mealNutrition)
    
    return safeyMealNutrition.toFoodInfo()
  }
}
