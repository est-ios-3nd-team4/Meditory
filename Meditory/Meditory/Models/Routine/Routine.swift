import Foundation
import SwiftData

@Model
final class Routine {
    @Attribute(.unique) var id: UUID
    var type: Int  // 1: 영양제, 2: 약
    var name: String
    var cycleType: Int  // 1: 요일별, 2: 주기별
    var cycleValue: String  // 0~6: 일~토, 11~19: 1일~9일 간격
    var startDate: Date
    var timesPerDay: Int
    var pillsPerDose: Int
    var memo: String?
    var hasPush: Bool
    var imageData: Data?
    var productName: String?
    var productDescription: String?
    var notWith: String?
    var whenToTake: String?

    @Relationship(deleteRule: .cascade)
    var routineTimes: [RoutineTime] = []

    init(id: UUID = UUID(), type: Int, name: String, cycleType: Int, cycleValue: String, startDate: Date, timesPerDay: Int, pillsPerDose: Int, memo: String? = nil, hasPush: Bool, imageData: Data? = nil, productName: String? = nil, productDescription: String? = nil, notWith: String? = nil, whenToTake: String? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.cycleType = cycleType
        self.cycleValue = cycleValue
        self.startDate = startDate
        self.timesPerDay = timesPerDay
        self.pillsPerDose = pillsPerDose
        self.memo = memo
        self.hasPush = hasPush
        self.imageData = imageData
        self.productName = productName
        self.productDescription = productDescription
        self.notWith = notWith
        self.whenToTake = whenToTake
    }
}
