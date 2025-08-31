//
//  ModelConvertibles.swift
//
//  이 파일은 SwiftData 엔티티(@Model)와 일반 데이터 모델(Struct/Class) 간의 상호 변환을 위한 초기화(Initializer)를 정의함.
//  데이터베이스 계층과 비즈니스 로직/UI 계층 간의 객체 매핑을 용이하게 하는 역할을 함.
//

import Foundation
import SwiftData

// MARK: - Food <-> FoodInfo 변환

/// `Food` 엔티티는 `FoodInfo` 데이터 모델로부터 생성될 수 있음.
extension Food {
  /// `FoodInfo` 데이터 모델을 사용하여 `Food` 엔티티 인스턴스를 편리하게 생성함.
  ///
  /// - Parameter model: 데이터베이스 엔티티로 변환할 `FoodInfo` 모델 객체임.
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

/// `FoodInfo` 데이터 모델은 `Food` 엔티티로부터 생성될 수 있음.
extension FoodInfo {
  /// `Food` 엔티티를 사용하여 `FoodInfo` 데이터 모델 인스턴스를 생성함.
  ///
  /// - Parameter entity: 데이터 모델로 변환할 `Food` 엔티티 객체임.
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

/// `Meal` 엔티티는 `MealInfo` 데이터 모델로부터 생성될 수 있음.
extension Meal {
  /// `MealInfo` 데이터 모델을 사용하여 `Meal` 엔티티 인스턴스를 편리하게 생성함.
  ///
  /// 이 과정에서 `MealInfo`에 포함된 모든 `FoodInfo` 객체들도 `Food` 엔티티로 변환됨.
  /// - Parameter model: 데이터베이스 엔티티로 변환할 `MealInfo` 모델 객체임.
  convenience init(model: MealInfo) {
    self.init(
      id: model.id,
      mealName: model.name,
      date: model.date,
      foods: model.foods.map { Food(model: $0) } // 중첩된 FoodInfo 배열도 변환함
    )
  }
}

/// `MealInfo` 데이터 모델은 `Meal` 엔티티로부터 생성될 수 있음.
extension MealInfo {
  /// `Meal` 엔티티를 사용하여 `MealInfo` 데이터 모델 인스턴스를 생성함.
  ///
  /// 이 과정에서 `Meal`에 포함된 모든 `Food` 엔티티들도 `FoodInfo` 객체로 변환됨.
  /// - Parameter entity: 데이터 모델로 변환할 `Meal` 엔티티 객체임.
  init(entity: Meal) {
    self.id = entity.id
    self.name = entity.mealName
    self.date = entity.date
    self.foods = entity.foods.map { FoodInfo(entity: $0) } // 중첩된 Food 엔티티 배열도 변환함
  }
}
