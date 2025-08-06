import SwiftData
import Foundation

@Model
class NutrientRecommendation {
    @Attribute(.unique) var id: String
    var userId: String
    var nutrientId: String
    var date: Date
    var content: String

    init(id: String, userId: String, nutrientId: String, date: Date, content: String) {
        self.id = id
        self.userId = userId
        self.nutrientId = nutrientId
        self.date = date
        self.content = content
    }
}
