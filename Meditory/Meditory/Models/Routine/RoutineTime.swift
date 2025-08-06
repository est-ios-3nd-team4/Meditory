import SwiftData
import Foundation

@Model
final class RoutineTime {
    @Attribute(.unique) var id: UUID
    var time: Date

    @Relationship var routine: Routine?

    init(id: UUID = UUID(), time: Date, routine: Routine? = nil) {
        self.id = id
        self.time = time
        self.routine = routine
    }
}
