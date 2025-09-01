//
//  NutritionMainViewModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/18/25.
//

import SwiftUI
import SwiftData

/// `NutritionMainViewModel`
/// - 영양 관리 앱의 핵심 비즈니스 로직을 담당하는 메인 ViewModel 클래스입니다.
/// - MVVM 패턴에서 Model과 View 사이의 중간 역할을 하며, 데이터 관리와 UI 상태 관리를 담당합니다.
/// - SwiftData 기반 로컬 데이터베이스, HealthKit 연동, AI API 통신 등 다양한 데이터 소스를 통합 관리합니다.
///
/// ## 주요 기능
/// - **식단 관리**: 음식 등록, 수정, 삭제 및 일별 식단 조회
/// - **영양소 계산**: 매크로 영양소 비율, 권장량 대비 섭취량 계산
/// - **HealthKit 연동**: 걸음 수 기반 활동량 측정 및 권장 칼로리 계산
/// - **사용자 관리**: 개인 신체 정보 관리 및 맞춤형 권장량 제공
/// - **AI 영양 분석**: 음식명 기반 자동 영양 정보 조회 및 등록
///
/// ## 데이터 흐름
/// ```
/// View ↔ NutritionMainViewModel ↔ [SwiftData, HealthKit, API]
/// ```
///
/// ## 사용 예시
/// ```swift
/// @StateObject private var nutritionVM = NutritionMainViewModel(modelContext: context)
///
/// // 음식 등록
/// nutritionVM.registerFood(name: "닭가슴살",
///                         macros: MacroNutrients(carbohydrate: 0, protein: 25, fat: 2))
///
/// // 일별 식단 조회
/// await nutritionVM.loadMealsForDate(Date())
///
/// // 매크로 비율 확인
/// let ratio = nutritionVM.macroPercent
/// ```
@MainActor
class NutritionMainViewModel: ObservableObject {
  
  // MARK: - Published Properties
  
  /// 현재 선택된 날짜의 식단 목록
  /// - SwiftData에서 로드된 `Meal` 엔티티를 UI 친화적인 `MealInfo` DTO로 변환하여 저장
  /// - `selectedDate` 변경시 자동으로 해당 날짜의 데이터로 업데이트됨
  /// - UI에서 식단 목록 표시, 편집, 삭제 등에 사용
  
  @Published var meals: [MealInfo] = []
  
  /// 사용자가 현재 선택한 날짜
  /// - 캘린더 UI와 바인딩되어 날짜 변경시 실시간 반영
  /// - 이 값이 변경되면 `loadMealsForDate(_:)` 호출하여 해당 날짜 식단 로드
  /// - 기본값: 현재 날짜 (`Date()`)
  @Published var selectedDate = Date()
  
  /// 현재 선택된 날짜의 대표 식단 (첫 번째 식단)
  /// - `meals` 배열에서 `selectedDate`와 같은 날짜의 첫 번째 식단 반환
  /// - 새 음식 등록시 이 식단에 추가되거나, 없으면 새 식단 생성
  /// - Computed property로 실시간 계산됨
  var selectedMeal: MealInfo? {
    meals.first {
      Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
    }
  }
  
  /// HealthKit 데이터 관리를 담당하는 매니저 인스턴스
  /// - 걸음 수 조회, 권한 관리, 활동량 계산 등을 처리
  /// - 권장 칼로리 계산시 활동량 기준으로 사용됨
  @Published var healthKitManager = HealthKitManager()
  
  /// SwiftData ModelContext - 데이터베이스 작업을 위한 컨텍스트
  /// - 앱 초기화시 주입받아 모든 CRUD 작업에 사용
  /// - Meal, Food, User 엔티티의 생성, 조회, 수정, 삭제 담당
  
  private let modelContext: ModelContext
  
  // MARK: - SwiftData - User Properties
  
  /// 현재 로그인한 사용자 정보
  /// - `UserStore`를 통해 로드된 사용자 데이터
  /// - 신체 정보 기반 권장 칼로리 계산에 사용
  @Published var currentUser: User?
  
  /// 사용자 키 (cm)
  /// - 권장 칼로리 계산시 BMR(기초대사율) 산출에 사용
  /// - `nil`인 경우 기본값 170cm으로 계산
  @Published var userHeight: Double?
  
  /// 사용자 몸무게 (kg)
  /// - 권장 칼로리 계산시 BMR 산출에 사용
  /// - `nil`인 경우 기본값 60kg으로 계산
  @Published var userWeight: Double?
  
  /// 사용자 나이 (세)
  /// - BMR 계산 공식에 사용되는 필수 파라미터
  /// - Harris-Benedict Equation 적용
  @Published var userAge: Int = 0
  
  /// 사용자 성별 ("male" 또는 "female")
  /// - BMR 계산시 남녀 구분을 위해 사용
  /// - 남성: "male", 여성: "female"
  @Published var userGender: String = ""
  
  /// 사용자 맞춤 일일 권장 매크로 영양소량
  /// - 신체 정보 + HealthKit 활동량을 기반으로 계산된 개인별 권장량
  /// - 탄수화물(g), 단백질(g), 지방(g) 포함
  /// - UI에서 목표 대비 달성률 표시에 사용
  @Published var recommendedCalories = MacroNutrients(carbohydrate: 0,
                                                      protein: 0,
                                                      fat: 0) // 권장 Macro
  
  // MARK: - Computed Properties
  
  /// 현재 선택된 날짜의 모든 음식 목록 (평면화)
  /// - `meals` 배열의 모든 식단에서 음식들을 추출하여 하나의 배열로 반환
  /// - UI에서 음식 카드 목록 표시시 사용
  /// - Returns: 모든 음식을 담은 `[FoodInfo]` 배열
  var foodList: [FoodInfo] { meals.flatMap { $0.foods } }
  
  /// 권장량 대비 실제 섭취 비율 (0.0 ~ 1.0+)
  /// - 실제 섭취량 ÷ 권장량으로 계산
  /// - 1.0 = 100% 달성, 1.5 = 150% 달성
  /// - 권장량이 0인 경우 0으로 처리하여 division by zero 방지
  /// - Returns: 각 매크로별 달성 비율을 담은 `MacroNutrients`
  var macroRatio: MacroNutrients {
    let totalMacros = foodList.reduce(into: MacroNutrients(carbohydrate: 0,
                                                           protein: 0,
                                                           fat: 0)) { result, food in
      result.carbohydrate += food.macros.carbohydrate
      result.protein += food.macros.protein
      result.fat += food.macros.fat
    }
    
    return MacroNutrients(carbohydrate: recommendedCalories.carbohydrate > 0
                          ? (totalMacros.carbohydrate / recommendedCalories.carbohydrate)
                          : 0,
                          protein: recommendedCalories.protein > 0
                          ? (totalMacros.protein / recommendedCalories.protein)
                          : 0,
                          fat: recommendedCalories.fat > 0
                          ? (totalMacros.fat / recommendedCalories.fat)
                          : 0)
  }
  
  /// 권장량 대비 실제 섭취 백분율 (0 ~ 100+)
  /// - `macroRatio`에 100을 곱한 값
  /// - UI 진행률 표시, 원형 차트 등에서 사용
  /// - Returns: 각 매크로별 달성 퍼센트를 담은 `MacroNutrients`
  ///
  /// ## 사용 예시
  /// ```swift
  /// let percent = viewModel.macroPercent
  /// print("탄수화물 달성률: \(percent.carbohydrate)%")
  /// // 출력: "탄수화물 달성률: 85.5%"
  /// ```
  var macroPercent: MacroNutrients {
    MacroNutrients(carbohydrate: macroRatio.carbohydrate * 100,
                   protein: macroRatio.protein * 100,
                   fat: macroRatio.fat * 100)
  }
  
  /// ViewModel 초기화
  /// - Parameter modelContext: SwiftData 데이터베이스 컨텍스트
  /// - 초기화와 동시에 HealthKit 권한 확인 및 사용자 데이터 로드 시작
  ///
  /// ## 초기화 과정
  /// 1. ModelContext 저장
  /// 2. HealthKit 권한 상태 확인
  /// 3. 권한이 있으면 걸음 수 데이터 로드
  /// 4. 사용자 기본 정보 로드 (키, 몸무게, 나이 등)
  /// 5. 권장 칼로리 계산 및 설정
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    
    Task {
      if healthKitManager.checkCurrentAuthorizationStatus() {
        await healthKitManager.loadTodaySteps()
      }
      
      await loadUserData() // 사용자 데이터 load
    }
  }
  
  /// HealthKit 사용 권한을 요청하고 걸음 수 데이터를 로드
  /// - 이미 권한이 있으면 즉시 데이터 로드
  /// - 권한이 없으면 시스템 다이얼로그를 통해 권한 요청
  /// - 권한 여부와 관계없이 기본 정보 기반 권장 칼로리는 계산
  ///
  /// ## 실행 순서
  /// 1. 현재 권한 상태 확인
  /// 2. 권한 있음 → 걸음 수 로드 후 권장 칼로리 업데이트
  /// 3. 권한 없음 → 권한 요청 → 성공시 걸음 수 로드
  /// 4. 실패해도 기본 권장 칼로리는 계산하여 앱 기능 유지
  ///
  /// ## 에러 처리
  /// - HealthKit 권한 거부시에도 앱 기본 기능은 정상 동작
  /// - 걸음 수 없이도 신체 정보 기반 권장량은 제공
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
  
  /// 사용자 신체 정보와 HealthKit 활동량을 기반으로 권장 칼로리 계산 및 업데이트
  /// - Harris-Benedict Equation을 사용한 BMR 계산
  /// - 걸음 수 기반 활동 계수 적용
  /// - 계산 결과를 `recommendedCalories` 프로퍼티에 저장
  ///
  /// ## 계산 공식
  /// ```
  /// BMR = Harris-Benedict Equation (성별, 나이, 키, 몸무게)
  /// Daily Calories = BMR × Activity Factor (걸음 수 기반)
  /// Macros = Daily Calories 기반 탄단지 비율 분배
  /// ```
  ///
  /// ## 필수 조건
  /// - `userWeight`, `userHeight`가 모두 설정되어 있어야 함
  /// - 없으면 계산 생략하고 경고 로그 출력
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
  
  /// 현재 선택된 날짜의 모든 매크로 영양소 합계 (Deprecated - todayTotalMacros 대신 사용)
  /// - `meals` 배열의 모든 식단에서 매크로 영양소를 합산
  /// - Returns: 총 탄수화물, 단백질, 지방 섭취량을 담은 `MacroNutrients`
  ///
  /// **참고**: 이 프로퍼티는 `foodList.reduce`를 통해 더 효율적으로 계산할 수 있으므로
  /// 추후 제거 예정입니다. 대신 computed property 활용을 권장합니다.
  var todayTotalMacros: MacroNutrients {
    meals.reduce(MacroNutrients(carbohydrate: 0,
                                protein: 0,
                                fat: 0)) { result, macro in
      MacroNutrients(carbohydrate: result.carbohydrate + macro.macros.carbohydrate,
                     protein: result.protein + macro.macros.protein,
                     fat: result.fat + macro.macros.fat)
    }
  }
  
  /// 특정 음식이 속한 식단(Meal) 찾기
  /// - Parameter foodId: 찾을 음식의 고유 식별자
  /// - Returns: 해당 음식을 포함한 식단 정보 (`MealInfo?`)
  /// - 음식 편집/삭제시 어떤 식단에 속해있는지 확인할 때 사용
  ///
  /// ## 사용 예시
  /// ```swift
  /// if let meal = viewModel.findMeal(for: foodId) {
  ///     print("음식이 포함된 식단: \(meal.name)")
  ///     // 해당 식단에서 음식 편집/삭제 수행
  /// }
  /// ```
  func findMeal(for foodId: UUID) -> MealInfo? {
    return meals.first { meal in
      meal.foods.contains { $0.id == foodId }
    }
  }
  
}

// MARK: RecommendedMacroCalculator
/// 권장 매크로 영양소 계산 관련 확장
/// - 사용자 신체 정보와 활동량을 기반으로 개인별 권장 영양소량 계산
/// - `RecommendedMacroCalculator` 유틸리티 클래스를 활용한 래퍼 메서드 제공

extension NutritionMainViewModel {
  
  /// 개인별 맞춤 매크로 영양소 가이드 계산
  /// - Parameters:
  ///   - weight: 몸무게 (kg)
  ///   - height: 키 (cm)
  ///   - age: 나이 (세)
  ///   - isMale: 성별 (true: 남성, false: 여성)
  /// - Returns: 일일 권장 매크로 영양소량 (`MacroNutrients`)
  ///
  /// ## 계산 과정
  /// 1. **BMR 계산**: Harris-Benedict 공식으로 기초대사율 산출
  /// 2. **활동 계수 적용**: HealthKit 걸음 수 기반 활동량 반영
  /// 3. **일일 칼로리 계산**: BMR × 활동 계수
  /// 4. **매크로 분배**: 칼로리를 탄수화물(45-65%), 단백질(10-35%), 지방(20-35%) 비율로 분배
  ///
  /// ## 활동 계수 기준
  /// - 좌식생활 (< 3000보): 1.2
  /// - 가벼운 활동 (3000-7000보): 1.375
  /// - 보통 활동 (7000-10000보): 1.55
  /// - 활발한 활동 (10000-12500보): 1.725
  /// - 극도로 활발 (> 12500보): 1.9
  func getMacroGuide(weight: Double, height: Double, age: Int, isMale: Bool) -> MacroNutrients {
    let activityLevel = healthKitManager.getActivityLevel()
    
    let bmr = RecommendedMacroCalculator.calculateBMR(weight: weight, height: height, age: age, isMale: isMale)
    
    let calories = RecommendedMacroCalculator.calculateDailyCalories(bmr: bmr, activityLevel: activityLevel)
    
    return RecommendedMacroCalculator.calculateMacros(dailyCalories: calories)
  }
}

// MARK: - SwiftData-User
/// 사용자 데이터 관리 관련 확장
/// - `UserStore`를 통한 사용자 정보 로드 및 관리
/// - 신체 정보 기반 권장 칼로리 자동 계산
extension NutritionMainViewModel {
  
  /// UserStore에서 사용자 데이터를 로드하여 ViewModel에 설정
  /// - `UserStore.shared`를 통해 싱글톤 패턴으로 사용자 데이터 조회
  /// - 로드된 정보로 즉시 권장 칼로리 계산 및 설정
  ///
  /// ## 로드되는 데이터
  /// - `currentUser`: 전체 사용자 객체
  /// - `userHeight`: 키 (cm)
  /// - `userWeight`: 몸무게 (kg)
  /// - `userAge`: 나이 (세)
  /// - `userGender`: 성별 ("male"/"female")
  /// - `recommendedCalories`: 계산된 권장 매크로 영양소량
  ///
  /// ## 에러 처리
  /// - 사용자 데이터 로드 실패시 콘솔 에러 출력
  /// - 앱 기본 기능은 계속 사용 가능 (기본값 적용)
  ///
  /// ## 사용 시점
  /// - 앱 시작시 (ViewModel init)
  /// - 사용자 정보 변경 후 재계산 필요시
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
/// 식단 및 음식 데이터 관리 관련 확장
/// - SwiftData를 통한 Meal, Food 엔티티 CRUD 작업
/// - UI 상태와 데이터베이스 상태 동기화 관리
/// - 음식 등록, 수정, 삭제 및 식단 관리 기능
extension NutritionMainViewModel {
  
  /// 새 음식을 등록하거나 기존 식단에 추가
  /// - Parameters:
  ///   - name: 음식 이름 (빈 문자열 불가)
  ///   - macros: 매크로 영양소 정보 (탄수화물, 단백질, 지방)
  ///
  /// ## 등록 로직
  /// 1. **기존 식단 있음**: `selectedMeal`에 음식 추가 (`updateMealWithFood`)
  /// 2. **기존 식단 없음**: 새 식단 생성 후 음식 추가 (`createNewMealWithFood`)
  ///
  /// ## 데이터 흐름
  /// 1. `FoodInfo` DTO 생성
  /// 2. SwiftData `Food` 엔티티로 변환
  /// 3. 데이터베이스에 저장
  /// 4. UI 상태 (`meals`) 업데이트
  ///
  /// ## 사용 예시
  /// ```swift
  /// let macros = MacroNutrients(carbohydrate: 30, protein: 25, fat: 5)
  /// viewModel.registerFood(name: "닭가슴살 샐러드", macros: macros)
  /// ```
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
    
    if let selectedMeal = selectedMeal {
      updateMealWithFood(mealId: selectedMeal.id, food: food)
    } else {
      createNewMealWithFood(food: food)
    }
  }
  
  /// 기존 식단에 음식 추가
  /// - Parameters:
  ///   - mealId: 대상 식단의 고유 식별자
  ///   - food: 추가할 음식 엔티티
  ///
  /// ## 실행 과정
  /// 1. 식단 ID로 데이터베이스에서 `Meal` 엔티티 조회
  /// 2. 해당 식단의 `foods` 배열에 새 음식 추가
  /// 3. 데이터베이스에 변경사항 저장
  /// 4. UI 상태 (`meals`) 배열 업데이트
  ///
  /// ## 에러 처리
  /// - 식단을 찾을 수 없으면 새 식단 생성으로 대체
  /// - 데이터베이스 저장 실패시 에러 로그 출력
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
  
  /// 새로운 식단을 생성하고 음식 추가
  /// - Parameter food: 새 식단에 포함할 첫 번째 음식
  ///
  /// ## 생성 과정
  /// 1. 기존 식단 재확인 (중복 생성 방지)
  /// 2. 새 `Meal` 엔티티 생성 (이름은 빈 문자열, 현재 선택 날짜 적용)
  /// 3. 음식과 함께 데이터베이스에 저장
  /// 4. UI용 `MealInfo` DTO 생성하여 `meals` 배열에 추가
  ///
  /// ## 특징
  /// - 식단 이름(`mealName`)은 빈 문자열로 시작 (사용자가 나중에 설정 가능)
  /// - 현재 선택된 날짜(`selectedDate`)로 식단 날짜 설정
  /// - 생성 즉시 첫 번째 음식이 포함된 상태
  private func createNewMealWithFood(food: Food) {
    if let existingMeal = selectedMeal {
      updateMealWithFood(mealId: existingMeal.id, food: food)
    } else {
      
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
        
        print("✅ 새 식단이 생성되었습니다")
        print("name: \(newMeal.foods), date : \(newMeal.date)")
      } catch {
        print("❌ Meal 생성 실패: \(error)")
      }
    }
  }
  
  /// 특정 날짜의 모든 식단 데이터를 데이터베이스에서 로드
  /// - Parameter date: 조회할 날짜
  ///
  /// ## 조회 범위
  /// - **시작**: 해당 날짜 자정 (00:00:00)
  /// - **종료**: 다음 날 자정 직전 (23:59:59.999)
  /// - **정렬**: 날짜순 오름차순
  ///
  /// ## 데이터 변환
  /// - SwiftData `Meal` 엔티티 → UI용 `MealInfo` DTO 변환
  /// - 연관된 `Food` 엔티티들도 `FoodInfo` DTO로 변환
  /// - 변환된 데이터를 `meals` 프로퍼티에 저장하여 UI 업데이트
  ///
  /// ## 비동기 처리
  /// - 데이터베이스 조회는 백그라운드에서 실행
  /// - 결과는 `@MainActor.run`을 통해 UI 스레드에서 업데이트
  ///
  /// ## 사용 예시
  /// ```swift
  /// // 오늘 식단 로드
  /// await viewModel.loadMealsForDate(Date())
  ///
  /// // 특정 날짜 식단 로드
  /// let targetDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
  /// await viewModel.loadMealsForDate(targetDate)
  /// ```
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
  
  /// 현재 선택된 날짜의 식단 데이터 로드 (래퍼 메서드)
  /// - `loadMealsForDate(selectedDate)`의 편의 메서드
  /// - 주로 앱 초기화나 날짜 변경 없이 현재 데이터 새로고침시 사용
  ///
  /// ## 사용 시점
  /// - 앱 시작시 오늘 식단 로드
  /// - 음식 등록/수정/삭제 후 최신 상태 반영
  /// - 다른 화면에서 돌아온 후 데이터 동기화
  func loadMealForSelectedDate() async {
    await loadMealsForDate(selectedDate)
    print("func loadMealForSelectedDate() async called")
  }
  
}

// MARK: - ViewModel Extension for Food Management
/// 음식 수정/삭제 관련 확장
/// - 기존 음식 정보 업데이트 및 삭제 기능
/// - 식단이 비어있을 경우 자동으로 식단도 함께 삭제
/// - UI 상태와 데이터베이스 동기화 보장
extension NutritionMainViewModel {
  
  /// 기존 음식 정보를 수정
  /// - Parameters:
  ///   - foodId: 수정할 음식의 고유 식별자
  ///   - mealId: 해당 음식이 속한 식단의 고유 식별자
  ///   - name: 새 음식 이름
  ///   - macros: 새 매크로 영양소 정보
  ///
  /// ## 수정 과정
  /// 1. 음식 ID로 데이터베이스에서 `Food` 엔티티 조회
  /// 2. 엔티티의 속성값들 업데이트 (이름, 탄수화물, 단백질, 지방)
  /// 3. 데이터베이스에 변경사항 저장
  /// 4. UI 상태 (`meals`) 배열에서 해당 음식 정보 업데이트
  ///
  /// ## 에러 처리
  /// - 음식을 찾을 수 없으면 에러 로그 출력 후 작업 중단
  /// - 데이터베이스 저장 실패시 에러 로그 출력
  ///
  /// ## 사용 예시
  /// ```swift
  /// let updatedMacros = MacroNutrients(carbohydrate: 25, protein: 30, fat: 8)
  /// viewModel.updateFood(foodId: foodId,
  ///                     mealId: mealId,
  ///                     name: "구운 닭가슴살",
  ///                     macros: updatedMacros)
  /// ```
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
  
  /// 음식을 삭제하고, 식단이 비어있으면 식단도 함께 삭제
  /// - Parameters:
  ///   - foodId: 삭제할 음식의 고유 식별자
  ///   - mealId: 해당 음식이 속한 식단의 고유 식별자
  ///
  /// ## 삭제 과정
  /// 1. 음식 ID로 데이터베이스에서 `Food` 엔티티 조회 및 삭제
  /// 2. UI 상태에서 해당 음식 제거
  /// 3. 식단에 더 이상 음식이 없으면 식단(`Meal`)도 함께 삭제
  /// 4. UI 상태에서 빈 식단 제거
  ///
  /// ## 연쇄 삭제
  /// - 마지막 음식 삭제시 → 빈 식단도 자동 삭제
  /// - 데이터 일관성 유지 및 불필요한 빈 식단 방지
  ///
  /// ## 에러 처리
  /// - 음식을 찾을 수 없으면 에러 로그 출력
  /// - 데이터베이스 작업 실패시 에러 로그 출력
  ///
  /// ## 사용 예시
  /// ```swift
  /// // 음식 삭제 (식단에 다른 음식이 있으면 식단 유지)
  /// viewModel.deleteFood(foodId: foodId, mealId: mealId)
  ///
  /// // 마지막 음식 삭제시 식단도 함께 삭제됨
  /// ```
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
        }
      }
      
      print("✅ 음식이 성공적으로 삭제되었습니다")
    } catch {
      print("❌ 음식 삭제 실패: \(error)")
    }
  }
  
}

// MARK: - Network
/// AI API 통신 관련 확장
/// - 음식명 기반 자동 영양 정보 조회
/// - API 응답 파싱 및 에러 처리
/// - 안전한 기본값 제공으로 앱 안정성 보장
extension NutritionMainViewModel {
  
  /// AI API를 통해 음식명 기반 영양 정보 조회
  /// - Parameter mealName: 조회할 음식 이름
  /// - Returns: AI가 분석한 영양 정보 (`FoodInfo`)
  /// - Throws: API 통신 관련 에러
  ///
  /// ## API 요청 과정
  /// 1. 음식명을 기반으로 AI 프롬프트 생성
  /// 2. `AlanAPIClient`를 통해 API 서버에 요청
  /// 3. JSON 형태의 응답을 `MealNutrition` 객체로 파싱
  /// 4. UI 친화적인 `FoodInfo` DTO로 변환하여 반환
  ///
  /// ## 안전성 보장
  /// - API 응답 파싱 실패시 안전한 기본값 제공
  /// - 기본값: "알 수 없음" 이름과 0g 영양소
  /// - 앱 크래시 방지 및 사용자 경험 보장
  ///
  /// ## 사용 예시
  /// ```swift
  /// do {
  ///     let foodInfo = try await viewModel.request(mealName: "김치찌개")
  ///     print("영양 정보: \(foodInfo.macros)")
  /// } catch {
  ///     print("API 조회 실패: \(error)")
  /// }
  /// ```
  ///
  /// ## 응답 처리
  /// - **성공**: 실제 영양 정보 반환
  /// - **파싱 실패**: "알 수 없음" + 0g 영양소 반환
  /// - **API 에러**: 에러 throw (호출자에서 처리)
  func request(mealName: String) async throws -> FoodInfo {
    print("✅ 요청", Date.now)
    let prompt = MealNutritionPrompt.makePrompt(mealName: mealName)
    
    let response = try await AlanAPIClient().request(content: prompt)
    
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
