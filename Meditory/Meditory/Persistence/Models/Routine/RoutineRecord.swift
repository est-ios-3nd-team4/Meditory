import Foundation
import SwiftData

@Model
final class RoutineRecord {
    @Attribute(.unique) var id: UUID
    var timestamp: Date

    @Relationship var routine: Routine?

    init(id: UUID = UUID(), timestamp: Date = Date(), routine: Routine? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.routine = routine
    }
}
