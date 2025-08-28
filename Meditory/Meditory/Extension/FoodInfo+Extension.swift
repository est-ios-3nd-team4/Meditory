//
//  FoodInfo+Extension.swift
//  Meditory
//
//  Created by 이치훈 on 8/27/25.
//

import Foundation

extension FoodInfo {
  func toFood() -> Food {
    return Food(id: id,
                foodName: name,
                totalGram: weight,
                carbohydrate: macros.carbohydrate,
                protein: macros.protein,
                fat: macros.fat)
  }
}
