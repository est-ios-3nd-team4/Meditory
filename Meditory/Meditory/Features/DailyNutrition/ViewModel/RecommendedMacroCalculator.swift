//
//  NutritionCalculator.swift
//  Meditory
//
//  Created by 이치훈 on 8/20/25.
//

import Foundation

/// `RecommendedMacroCalculator`
/// - 사용자의 신체 정보와 활동량을 기반으로 개인별 권장 매크로 영양소량을 계산하는 유틸리티 구조체입니다.
/// - Harris-Benedict Equation과 영양학 가이드라인을 기반으로 한 과학적 계산 방식을 사용합니다.
/// - 모든 메서드는 static으로 구현되어 인스턴스 생성 없이 사용 가능합니다.
///
/// ## 계산 방식 개요
/// ```
/// BMR (기초대사율) → Daily Calories (일일 칼로리) → Macro Distribution (매크로 분배)
/// ```
///
/// ## 매크로 영양소 분배 비율
/// - **탄수화물**: 50% (4kcal/g)
/// - **단백질**: 30% (4kcal/g)
/// - **지방**: 20% (9kcal/g)
///
/// ## 사용 예시
/// ```swift
/// let bmr = RecommendedMacroCalculator.calculateBMR(weight: 70, height: 175, age: 30, isMale: true)
/// let dailyCalories = RecommendedMacroCalculator.calculateDailyCalories(bmr: bmr, activityLevel: .moderatelyActive)
/// let macros = RecommendedMacroCalculator.calculateMacros(dailyCalories: dailyCalories)
///
/// print("권장 탄수화물: \(macros.carbohydrate)g")
/// print("권장 단백질: \(macros.protein)g")
/// print("권장 지방: \(macros.fat)g")
/// ```
struct RecommendedMacroCalculator {
  
  /// Harris-Benedict Equation을 사용한 기초대사율(BMR) 계산
  /// - 나이, 성별, 키, 몸무게를 기반으로 하루 기본 소모 칼로리를 계산합니다.
  /// - 이 값은 생존에 필요한 최소 에너지량을 나타냅니다.
  ///
  /// - Parameters:
  ///   - weight: 몸무게 (kg)
  ///   - height: 키 (cm)
  ///   - age: 나이 (세)
  ///   - isMale: 성별 (true: 남성, false: 여성)
  /// - Returns: 기초대사율 (kcal/day)
  ///
  /// ## 계산 공식 (Revised Harris-Benedict Equation)
  /// - **남성**: BMR = (10 × 체중) + (6.25 × 키) - (5 × 나이) + 5
  /// - **여성**: BMR = (10 × 체중) + (6.25 × 키) - (5 × 나이) - 161
  ///
  /// ## 유효 범위
  /// - **나이**: 18-80세
  /// - **체중**: 30-200kg
  /// - **키**: 120-250cm
  ///
  /// ## 사용 예시
  /// ```swift
  /// // 30세 남성 (70kg, 175cm)
  /// let maleBMR = calculateBMR(weight: 70, height: 175, age: 30, isMale: true)
  /// // 결과: 약 1,728 kcal/day
  ///
  /// // 25세 여성 (55kg, 165cm)
  /// let femaleBMR = calculateBMR(weight: 55, height: 165, age: 25, isMale: false)
  /// // 결과: 약 1,340 kcal/day
  /// ```
  static func calculateBMR(weight: Double, height: Double, age: Int, isMale: Bool) -> Double {
    if isMale { // 남자 BMR 계산
      return (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
    } else { // 여자 BMR 계산
      return (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
    }
  }
  
  /// 활동량을 고려한 일일 권장 칼로리 계산
  /// - BMR에 활동 계수를 곱하여 실제 하루 소모 칼로리를 계산합니다.
  /// - HealthKit 걸음 수 데이터를 기반으로 한 개인별 맞춤 계산입니다.
  ///
  /// - Parameters:
  ///   - bmr: 기초대사율 (kcal/day) - `calculateBMR` 결과값 사용
  ///   - activityLevel: 활동 수준 (`ActivityLevel` enum) - 걸음 수 기반 분류
  /// - Returns: 일일 권장 총 칼로리 (kcal/day)
  ///
  /// ## 활동 계수 (Activity Factor)
  /// - **Sedentary (1.2)**: 좌식 생활, 거의 운동 안함 (< 3,000보)
  /// - **Lightly Active (1.375)**: 가벼운 활동 (3,000-7,000보)
  /// - **Moderately Active (1.55)**: 보통 활동 (7,000-10,000보)
  /// - **Very Active (1.725)**: 활발한 활동 (10,000-12,500보)
  /// - **Extremely Active (1.9)**: 극도로 활발 (> 12,500보)
  ///
  /// ## 계산 공식
  /// ```
  /// Daily Calories = BMR × Activity Factor
  /// ```
  ///
  /// ## 사용 예시
  /// ```swift
  /// let bmr = 1728.0 // 이전 단계에서 계산된 BMR
  /// let activityLevel = ActivityLevel.moderatelyActive // 걸음 수 기반
  /// let dailyCalories = calculateDailyCalories(bmr: bmr, activityLevel: activityLevel)
  /// // 결과: 1728 × 1.55 = 약 2,678 kcal/day
  /// ```
  static func calculateDailyCalories(bmr: Double, activityLevel: ActivityLevel) -> Double {
    return bmr * activityLevel.activityFactor
  }
  
  /// 일일 칼로리를 매크로 영양소별 그램 단위로 분배 계산
  /// - 총 칼로리를 탄수화물, 단백질, 지방의 권장 비율에 따라 분배합니다.
  /// - 각 영양소의 칼로리 밀도를 고려하여 그램 단위로 변환합니다.
  ///
  /// - Parameter dailyCalories: 일일 총 권장 칼로리 (kcal) - `calculateDailyCalories` 결과값 사용
  /// - Returns: 각 매크로 영양소별 권장 섭취량 (g) - `MacroNutrients`
  ///
  /// ## 매크로 영양소 분배 비율
  /// - **탄수화물**: 50% (주요 에너지원)
  /// - **단백질**: 30% (근육 유지 및 성장)
  /// - **지방**: 20% (호르몬 생성 및 지용성 비타민 흡수)
  ///
  /// ## 칼로리 밀도 (Caloric Density)
  /// - **탄수화물**: 4 kcal/g
  /// - **단백질**: 4 kcal/g
  /// - **지방**: 9 kcal/g
  ///
  /// ## 계산 공식
  /// ```
  /// 탄수화물(g) = (총 칼로리 × 0.5) ÷ 4
  /// 단백질(g) = (총 칼로리 × 0.3) ÷ 4
  /// 지방(g) = (총 칼로리 × 0.2) ÷ 9
  /// ```
  ///
  /// ## 사용 예시
  /// ```swift
  /// let dailyCalories = 2400.0 // 이전 단계에서 계산된 일일 칼로리
  /// let macros = calculateMacros(dailyCalories: dailyCalories)
  ///
  /// print("권장 탄수화물: \(macros.carbohydrate)g") // 300g
  /// print("권장 단백질: \(macros.protein)g")      // 180g
  /// print("권장 지방: \(macros.fat)g")            // 53.3g
  /// ```
  ///
  /// ## 영양학적 근거
  /// - 한국영양학회, WHO, FDA 가이드라인 기반
  /// - 일반 성인의 균형잡힌 영양소 섭취 비율 적용
  /// - 체중 관리 및 건강 유지에 적합한 비율
  static func calculateMacros(dailyCalories: Double) -> MacroNutrients {
    let carbCalories = dailyCalories * 0.5
    let proteinCalories = dailyCalories * 0.3
    let fatCalories = dailyCalories * 0.2
    
    return MacroNutrients(carbohydrate: carbCalories / 4,
                          protein: proteinCalories / 4,
                          fat: fatCalories / 9)
  }
  
}
