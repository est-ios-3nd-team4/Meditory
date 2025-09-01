//
//  MealNutritionPrompt.swift
//  Meditory
//
//  Created by 홍승아 on 8/27/25.
//

import Foundation

/// AI 모델에게 "식사명 → 영양소 정보" JSON 변환을 요청하기 위한 프롬프트 빌더
/// - 입력: 사용자가 입력한 식사명 (`mealName`)
/// - 출력: `{ type, name, carbohydrate, protein, fat }` 형식의 순수 JSON
/// - 목적: 추론된 음식명과 평균적인 탄수화물/단백질/지방(g 단위) 값을 제공
struct MealNutritionPrompt {
  
  /// AI가 반드시 따라야 할 기본 규칙
  private static let baseRules = """
  1. 출력은 순수 JSON만 반환하며, JSON 마크다운(```json)으로 감싸지 않습니다.
  2. 입력으로 주어진 `mealName`(음식명 또는 식단명)을 바탕으로, 가능한 한 정확하고 표준적인 음식명을 `"name"` 필드에 작성합니다.
     - 입력된 값이 약간 불완전하거나 잘못 쓰였더라도, 일반적으로 통용되는 표준 이름으로 수정/추론하여 작성합니다.
  3. `"carbohydrate"`, `"protein"`, `"fat"` 값은 음식의 일반적 평균 영양 성분을 기준으로 작성하며, 단위는 반드시 **그램(g)** 으로 표기합니다.
  4. `"type"` 필드를 반드시 포함해야 하며, 정상적으로 추론된 경우에는 0을 반환합니다.
  5. 모든 키(`type`, `name`, `carbohydrate`, `protein`, `fat`)는 반드시 포함해야 합니다.
  6. 불필요한 필드, 주석, 설명 문구는 절대 넣지 않습니다.
  7. 만약 입력된 `mealName`에 대한 정보를 전혀 추론할 수 없는 경우:
     - `"type"`은 `1`로 설정합니다.
     - `"name"`은 "알 수 없음"으로 작성합니다.
     - `"carbohydrate"`, `"protein"`, `"fat"` 값은 모두 `0`으로 설정합니다.
  """
  
  /// AI가 반환해야 하는 JSON 출력 스키마
  private static let outputSchema = """
  [출력 JSON 형식]
  {
    "type": Int,              // 0 = 정상 추론됨, 1 = 알 수 없음
    "name": "String",         // 추론된 음식명 (예: 김치 볶음밥, 한국식 비빔밥, 구운 삼겹살)
    "carbohydrate": Double,   // 탄수화물 (g)
    "protein": Double,        // 단백질 (g)
    "fat": Double             // 지방 (g)
  }
  """
  
  /// 최종 프롬프트 문자열 생성
  /// - Parameter mealName: 사용자 입력 음식명
  /// - Returns: AI 모델에 전달할 최종 프롬프트 문자열
  static func makePrompt(mealName: String) -> String {
    var sections: [String] = []
    
    sections.append("입력 음식명: \(mealName)")
    sections.append(baseRules)
    sections.append(outputSchema)
    
    return sections.joined(separator: "\n\n")
  }
}

