//
//  MealModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/12/25.
//

import Foundation

/// `MealInfo`
/// - 하나의 식단(식사)에 대한 전체 정보를 담는 데이터 전송 객체(DTO)입니다.
/// - 여러 음식들을 그룹화하여 아침, 점심, 저녁 등의 식사 단위로 관리합니다.
/// - SwiftData의 `Meal` 엔티티와 UI 계층 사이의 데이터 교환에 사용됩니다.
///
/// ## 주요 용도
/// - **식사 관리**: 시간대별 식단 구성 및 표시
/// - **영양소 집계**: 한 끼 식사의 총 영양소 계산
/// - **일별 조회**: 특정 날짜의 모든 식단 목록 관리
/// - **데이터 그룹화**: 개별 음식들을 의미있는 단위로 묶어서 관리
///
/// ## 데이터 구조
/// ```
/// MealInfo (하나의 식사)
///   ├── id: UUID (고유 식별자)
///   ├── name: String (식사명: "아침", "점심" 등)
///   ├── date: Date (식사 날짜)
///   ├── foods: [FoodInfo] (포함된 음식들)
///   └── macros: MacroNutrients (자동 계산된 총 영양소)
/// ```
///
/// ## 사용 예시
/// ```swift
/// let breakfast = MealInfo(
///     id: UUID(),
///     name: "아침",
///     date: Date(),
///     foods: [
///         FoodInfo(name: "계란후라이", weight: 60, macros: ...),
///         FoodInfo(name: "토스트", weight: 30, macros: ...)
///     ]
/// )
///
/// // 총 영양소 자동 계산
/// print("아침 총 단백질: \(breakfast.macros.protein)g")
///
/// // UI에서 표시
/// Text("\(breakfast.name): \(breakfast.foods.count)개 음식")
/// ```
struct MealInfo: Identifiable, Codable {
  var id: UUID
  var name: String // 식단 이름 (ex: 아침, 점심, 저녁)
  var date: Date // 날짜
  
  var foods: [FoodInfo] // 식단에 포함된 음식
  
  // totalMacro: 식단의 탄, 단, 지 총 합
  var macros: MacroNutrients {
    foods.reduce(MacroNutrients(carbohydrate: 0,
                                protein: 0,
                                fat: 0)) { result, food in
      MacroNutrients(carbohydrate: result.carbohydrate + food.macros.carbohydrate,
                     protein: result.protein + food.macros.protein,
                     fat: result.fat + food.macros.fat)
    }
  }
}
