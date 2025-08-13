import SwiftData
import SwiftUI

// MacroEntity
@Model
final class Macro {
    var macroTypeRawValue: String
    var gram: Double

    var macroType: MacroType {
        get { MacroType(rawValue: macroTypeRawValue) ?? .carbohydrate }
        set { macroTypeRawValue = newValue.rawValue }
    }

    var label: String { macroType.info.name }
    var color: Color { macroType.info.color }

    init(macroType: MacroType, gram: Double) {
        self.macroTypeRawValue = macroType.rawValue
        self.gram = gram
    }
}

// FoodEntity
@Model
final class Food {
    var foodName: String
    var totalGram: Double
    var macros: [Macro] = [] // Macro 1:N

    init(foodName: String, totalGram: Double, macros: [Macro]) {
        self.foodName = foodName
        self.totalGram = totalGram
        self.macros = macros
    }
}

// MealEntity
@Model
final class Meal {
    @Attribute(.unique) var id: UUID   // 항상 고유
    var mealName: String               // 식사명 (아침/점심/저녁 등)
    var date: Date
    var foods: [Food] = []

    init(id: UUID = UUID(), mealName: String, date: Date, foods: [Food]) {
        self.id = id
        self.mealName = mealName
        self.date = date
        self.foods = foods
    }
}

