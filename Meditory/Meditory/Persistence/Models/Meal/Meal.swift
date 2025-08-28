import SwiftData
import Foundation

@Model
final class Food {
  @Attribute(.unique) var id: UUID = UUID()   // 고유 아이디 추가
  var foodName: String
  var totalGram: Double
  
  // MacroNutrients 필드를 SwiftData 모델로 표현
  var carbohydrate: Double
  var protein: Double
  var fat: Double
  
  init(id: UUID, foodName: String, totalGram: Double,
       carbohydrate: Double, protein: Double, fat: Double) {
    self.foodName = foodName
    self.totalGram = totalGram
    self.carbohydrate = carbohydrate
    self.protein = protein
    self.fat = fat
  }
  
  // 편의 생성자 (UI 모델 변환용)
  convenience init(from foodInfo: FoodInfo) {
    self.init(id: foodInfo.id,
              foodName: foodInfo.name,
              totalGram: foodInfo.weight,
              carbohydrate: foodInfo.macros.carbohydrate,
              protein: foodInfo.macros.protein,
              fat: foodInfo.macros.fat)
  }
}

@Model
final class Meal {
  @Attribute(.unique) var id: UUID = UUID()
  var mealName: String
  var date: Date
  var foods: [Food] = []
  
  init(id: UUID, mealName: String, date: Date, foods: [Food]) {
    self.mealName = mealName
    self.date = date
    self.foods = foods
  }
  
  // totalMacro 계산을 위한 편의 계산 프로퍼티 (readonly)
  var carbohydrateTotal: Double {
    foods.reduce(0) { $0 + $1.carbohydrate }
  }
  
  var proteinTotal: Double {
    foods.reduce(0) { $0 + $1.protein }
  }
  
  var fatTotal: Double {
    foods.reduce(0) { $0 + $1.fat }
  }
  
  var totalMacros: MacroNutrients {
    MacroNutrients(carbohydrate: carbohydrateTotal,
                   protein: proteinTotal,
                   fat: fatTotal)
  }
}
