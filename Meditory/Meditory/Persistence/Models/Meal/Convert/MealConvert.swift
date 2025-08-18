// Meal(엔티티) <-> MealModel(UI용) 상호 변환 코드
// DB에서 불러올 때
//   `Meal` 엔티티만 조회 → `MealModel`로 변환 시 하위 `Food` 및 `Macro`까지 전부 매핑
// DB에 저장할때 
//   완성된 `MealModel` → `Meal` 엔티티로 변환하면 Food + Macro까지 한 번에 생성 → `context.insert()` → `context.save()`로 전체 저장 완료


//import SwiftData
//import SwiftUI
//
//// MARK: - MacroModel ↔ Macro 변환
//
//// SwiftData Macro → UI용 MacroModel 변환
//extension MacroModel {
//  init(entity: Macro) {
//    self.macroType = entity.macroType
//    self.gram = entity.gram
//  }
//}
//
//// UI용 MacroModel → SwiftData Macro 변환
//extension Macro {
//  convenience init(model: MacroModel) {
//    self.init(macroType: model.macroType, gram: model.gram)
//  }
//}
//
//
//// MARK: - FoodModel ↔ Food 변환
//
//// SwiftData Food → UI용 FoodModel 변환
//extension FoodModel {
//  init(entity: Food) {
//    self.foodName = entity.foodName
//    self.totalGram = entity.totalGram
//    // MacroEntity 배열에서 매크로 타입별로 값 추출
//    self.carbohydrate = entity.macros.first(where: { $0.macroType == .carbohydrate })?.gram ?? 0
//    self.protein = entity.macros.first(where: { $0.macroType == .protein })?.gram ?? 0
//    self.fat = entity.macros.first(where: { $0.macroType == .fat })?.gram ?? 0
//  }
//}
//
//// UI용 FoodModel → SwiftData Food 변환
//extension Food {
//  convenience init(model: FoodModel) {
//    self.init(
//      foodName: model.foodName,
//      totalGram: model.totalGram,
//      macros: [
//        Macro(model: model.carbohydrateModel), // 탄
//        Macro(model: model.proteinModel),      // 단
//        Macro(model: model.fatModel)           // 지
//      ]
//    )
//  }
//}
//
//
//// MARK: - MealModel ↔ Meal 변환
//
//// SwiftData Meal → UI용 MealModel 변환
//extension MealModel {
//  init(entity: Meal) {
//    self.id = entity.id
//    self.mealName = entity.mealName
//    self.date = entity.date
//    // 하위 FoodEntity들을 FoodModel로 변환
//    self.foods = entity.foods.map { FoodModel(entity: $0) }
//    // 하위 음식들의 매크로 합산
//    self.carbohydrate = foods.reduce(0) { $0 + $1.carbohydrate }
//    self.protein = foods.reduce(0) { $0 + $1.protein }
//    self.fat = foods.reduce(0) { $0 + $1.fat }
//  }
//}
//
//// UI용 MealModel → SwiftData Meal 변환
//extension Meal {
//  convenience init(model: MealModel) {
//    self.init(
//      id: model.id,
//      mealName: model.mealName,
//      date: model.date,
//      foods: model.foods.map { Food(model: $0) } // 하위 Food 변환 포함
//    )
//  }
//}
//
