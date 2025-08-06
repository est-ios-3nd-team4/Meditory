import Foundation
import SwiftData

@Model
final class Routine {
    @Attribute(.unique) var id: UUID
    var type: Int  // 1: 영양제, 2: 약
    var name: String
    var cycleType: Int  // 1: 요일별, 2: 주기별
    var cycleValue: Int  // 0~6: 일~토, 11~19: 1일~9일 간격
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

    init(id: UUID = UUID(), type: Int, name: String, cycleType: Int, cycleValue: Int, startDate: Date, timesPerDay: Int, pillsPerDose: Int, memo: String? = nil, hasPush: Bool, imageData: Data? = nil, productName: String? = nil, productDescription: String? = nil, notWith: String? = nil, whenToTake: String? = nil) {
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


extension Routine {
  convenience init(id: UUID = UUID(), type: Int = 1, name: String = "", cycleType: Int = 1, cycleValue: Int = 0, startDate: Date = .now, timesPerDay: Int = 1, pillsPerDose: Int = 1, hasPush: Bool = false) {
    self.init(
      id: id,
      type: type,
      name: name,
      cycleType: cycleType,
      cycleValue: cycleValue,
      startDate: startDate,
      timesPerDay: timesPerDay,
      pillsPerDose: pillsPerDose,
      memo: nil,
      hasPush: hasPush,
      imageData: nil,
      productName: nil,
      productDescription: nil,
      notWith: nil,
      whenToTake: nil
    )
  }
}

