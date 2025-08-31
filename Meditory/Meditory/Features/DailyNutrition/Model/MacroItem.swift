//
//  MacroModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/6/25.
//

import Foundation

// CoreModel

/// `MacroType`
/// - 매크로 영양소의 종류를 정의하는 열거형입니다.
/// - 영양 관리 앱에서 탄수화물, 단백질, 지방을 구분하는 핵심 타입입니다.
/// - `CaseIterable`을 통해 모든 매크로 타입을 순회할 수 있으며, UI 생성에 활용됩니다.
///
/// ## 매크로 영양소 분류
/// - **Carbohydrate (탄수화물)**: 주요 에너지원, 4kcal/g
/// - **Protein (단백질)**: 근육 구성 요소, 4kcal/g
/// - **Fat (지방)**: 호르몬 생성 및 에너지 저장, 9kcal/g
///
/// ## 사용 예시
/// ```swift
/// // 모든 매크로 타입 순회
/// ForEach(MacroType.allCases, id: \.self) { type in
///     Text(type.rawValue)
/// }
///
/// // 특정 타입 확인
/// let type = MacroType.protein
/// print(type.rawValue) // "protein"
/// ```
enum MacroType: String, Codable, CaseIterable {
  case carbohydrate
  case protein
  case fat
}

/// `MacroItem`
/// - UI 표시를 위한 개별 매크로 영양소 아이템 정보를 담는 구조체입니다.
/// - `MacroNutrients`를 UI 친화적인 개별 아이템으로 변환할 때 사용됩니다.
/// - SwiftUI의 `ForEach`에서 직접 사용할 수 있도록 `Identifiable`을 구현합니다.
///
/// ## 주요 용도
/// - **UI 렌더링**: 매크로 영양소별 차트, 카드, 리스트 표시
/// - **개별 처리**: 각 영양소를 독립적으로 처리할 때
/// - **색상 매핑**: 영양소 타입별 고유 색상 적용
/// - **동적 생성**: `MacroNutrients`에서 배열 형태로 변환
///
/// ## 사용 예시
/// ```swift
/// let carbohydrateItem = MacroItem(type: .carbohydrate, gram: 150.5)
///
/// // UI에서 표시
/// Text("\(carbohydrateItem.type.rawValue): \(carbohydrateItem.gram)g")
///
/// // 색상 적용
/// Circle().fill(carbohydrateItem.type.color)
/// ```

struct MacroItem: Identifiable {
  var id: String { type.rawValue }
  let type: MacroType
  var gram: Double
}
