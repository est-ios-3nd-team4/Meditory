import Foundation
import SwiftData

// MARK: - Food <-> FoodInfo 변환

extension Food {
  convenience init(model: FoodInfo) {
    self.init(
      id: model.id,
      foodName: model.name,
      totalGram: model.weight,
      carbohydrate: model.macros.carbohydrate,
      protein: model.macros.protein,
      fat: model.macros.fat
    )
  }
}

extension FoodInfo {
  init(entity: Food) {
    self.id = entity.id
    self.name = entity.foodName
    self.weight = entity.totalGram
    self.macros = MacroNutrients(
      carbohydrate: entity.carbohydrate,
      protein: entity.protein,
      fat: entity.fat
    )
  }
}

// MARK: - Meal <-> MealInfo 변환

extension Meal {
  convenience init(model: MealInfo) {
    self.init(
      id: model.id,
      mealName: model.name,
      date: model.date,
      foods: model.foods.map { Food(model: $0) }
    )
  }
}

extension MealInfo {
  init(entity: Meal) {
    self.id = entity.id
    self.name = entity.mealName
    self.date = entity.date
    self.foods = entity.foods.map { FoodInfo(entity: $0) }
  }
}
