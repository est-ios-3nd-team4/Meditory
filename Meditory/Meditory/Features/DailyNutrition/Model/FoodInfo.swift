//
//  FoodModel.swift
//  Meditory
//
//  Created by 이치훈 on 8/13/25.
//

import Foundation

/// `FoodInfo`
/// - 개별 음식의 정보를 담는 데이터 전송 객체(DTO)입니다.
/// - SwiftData의 `Food` 엔티티와 UI 계층 사이의 데이터 교환에 사용됩니다.
/// - `Identifiable`, `Codable`, `Hashable` 프로토콜을 준수하여 SwiftUI와 데이터 처리에 최적화되어 있습니다.
///
/// ## 주요 용도
/// - **UI 표시**: SwiftUI View에서 음식 정보 렌더링
/// - **데이터 변환**: SwiftData ↔ UI 계층 간 데이터 전달
/// - **API 통신**: 서버와의 음식 정보 송수신
/// - **상태 관리**: ViewModel에서 임시 음식 데이터 보관
///
/// ## 데이터 관계
/// ```
/// MealInfo (식단)
///   └── foods: [FoodInfo] (음식 목록)
///       └── macros: MacroNutrients (영양소 정보)
/// ```
///
/// ## 사용 예시
/// ```swift
/// let chickenBreast = FoodInfo(
///     id: UUID(),
///     name: "닭가슴살 구이",
///     weight: 100.0,
///     macros: MacroNutrients(carbohydrate: 0, protein: 25.0, fat: 2.0)
/// )
///
/// // SwiftUI List에서 사용
/// ForEach(foods, id: \.id) { food in
///     Text("\(food.name): \(food.macros.protein)g 단백질")
/// }
/// ```
struct FoodInfo: Identifiable, Codable {
  var id: UUID
  var name: String // 음식 이름
  var weight: Double // 음식의 총 g 수
  var macros: MacroNutrients
}

/// `FoodInfo` Hashable 구현
/// - `id` 기반 동등성 비교 및 해시값 생성
/// - 같은 UUID를 가진 `FoodInfo`는 동일한 객체로 처리
/// - Set, Dictionary 등의 컬렉션에서 사용 가능
extension FoodInfo: Hashable {
  static func == (lhs: FoodInfo, rhs: FoodInfo) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
