import SwiftData
import Foundation

@Model
class Scrap {
    @Attribute(.unique) var id: String
    var userId: String
    var nutrientId: String
    var createdAt: Date

    init(id: String, userId: String, nutrientId: String, createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.nutrientId = nutrientId
        self.createdAt = createdAt
    }
}
