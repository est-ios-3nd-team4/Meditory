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
  
  
  
  // TODO: SwiftData 쿼리문으로 처리 예정
  //  var todayMeals: [MealInfo] {
  //    meals.filter { Calendar.current.isDate($0.date, inSameDayAs: selectredDate) }
  //  }
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    
    Task {
      //      try await healthKitManager.requestAuthorization()
      //      await healthKitManager.loadTodaySteps() // 사용자 걸음 수 load
      
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

// MARK: - SwiftData
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
