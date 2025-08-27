//
//  Food+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

extension Food {
  func toFoodInfo() -> FoodInfo {
    return FoodInfo(id: id,
                    name: foodName,
                    weight: totalGram,
                    macros: MacroNutrients(carbohydrate: carbohydrate,
                                           protein: protein,
                                           fat: fat))
  }
}
