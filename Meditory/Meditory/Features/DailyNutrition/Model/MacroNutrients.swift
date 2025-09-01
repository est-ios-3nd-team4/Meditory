//
//  MacroNutrients.swift
//  Meditory
//
//  Created by 이치훈 on 8/15/25.
//

import Foundation

/// `MacroNutrients`
/// - 매크로 영양소 3종(탄수화물, 단백질, 지방)의 함량을 저장하는 핵심 데이터 구조체입니다.
/// - 영양 관리 앱의 모든 영양소 계산과 표시에 사용되는 기본 단위입니다.
/// - `Codable`을 통해 JSON 직렬화가 가능하며, API 통신과 로컬 저장에 활용됩니다.
///
/// ## 주요 용도
/// - **실제 섭취량**: 사용자가 먹은 음식들의 영양소 합계
/// - **권장 섭취량**: 개인별 맞춤 일일 권장량
/// - **진행률 계산**: 목표 대비 달성률 (실제량 ÷ 권장량 × 100)
/// - **UI 데이터**: 차트, 진행률 바, 요약 카드 등의 데이터 소스
///
/// ## 데이터 관계
/// ```
/// User 신체정보 + 활동량 → MacroNutrients (권장량)
/// Food 영양소 합계 → MacroNutrients (실제 섭취량)
/// 권장량 vs 실제량 → 달성률 계산
/// ```
///
/// ## 사용 예시
/// ```swift
/// // 권장량 설정
/// let recommended = MacroNutrients(carbohydrate: 300, protein: 120, fat: 67)
///
/// // 실제 섭취량
/// let consumed = MacroNutrients(carbohydrate: 250, protein: 95, fat: 45)
///
/// // 달성률 계산
/// let ratio = consumed.carbohydrate / recommended.carbohydrate * 100 // 83.3%
///
/// // subscript 사용
/// print(consumed[.protein]) // 95.0
/// ```
struct MacroNutrients: Codable {
  var carbohydrate: Double // 탄수화물
  var protein: Double // 단백질
  var fat: Double // 지방
  
  subscript(type: MacroType) -> Double {
    get {
      switch type {
      case .carbohydrate: return carbohydrate
      case .protein: return protein
      case .fat: return fat
      }
    }
    set {
      switch type {
      case .carbohydrate: carbohydrate = newValue
      case .protein: protein = newValue
      case .fat: fat = newValue
      }
    }
  }
}
