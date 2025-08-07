import Foundation
import SwiftData

/// 클래스 형태로 구성된 홈 화면 전용 루틴 관리 매니저
@MainActor
final class HomeRoutineManager {
    private let context: ModelContext
    private let routineStore: RoutineStore

    /// ModelContext와 RoutineStore를 주입받아 초기화
    init(context: ModelContext, routineStore: RoutineStore = RoutineStore()) {
        self.context = context
        self.routineStore = routineStore
    }

    /// 단일 RoutineRecord 삭제
    func delete(record: RoutineRecord) {
        context.delete(record)
        try? context.save()
    }

    /// 특정 루틴/시간에 레코드가 있는지 여부
    func isCompleted(routine: Routine, at time: Date) -> Bool {
        let allRecords = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []
        return allRecords.contains { record in
            record.routine == routine &&
            Calendar.current.isDate(record.timestamp,
                                     equalTo: time,
                                     toGranularity: .minute)
        }
    }

    /// 오늘 날짜 기준 IntakeItem 목록 생성
    func fetchTodayIntakeItems(on date: Date) -> [IntakeItem] {
        let routines = routineStore.fetchRoutines(for: date, context: context)
        var items: [IntakeItem] = []
        
        for routine in routines {
            for time in routine.routineTimes {
                let completed = isCompleted(routine: routine, at: time.time)
                items.append(
                    IntakeItem(
                        id: time.id,
                        name: routine.name,
                        time: time.time,
                        isCompleted: completed,
                        routine: routine
                    )
                )
            }
        }
        
        return items.sorted { $0.time < $1.time }
    }

    /// IntakeItem 체크/언체크 토글: 레코드 생성 또는 삭제
    func toggleIntake(_ item: IntakeItem) {
        let allRecords = (try? context.fetch(FetchDescriptor<RoutineRecord>())) ?? []

        if item.isCompleted {
            // 이미 체크된 상태: 해당 시간의 레코드만 삭제
            if let recordToDelete = allRecords.first(where: { record in
                record.routine == item.routine &&
                Calendar.current.isDate(record.timestamp,
                                         equalTo: item.time,
                                         toGranularity: .minute)
            }) {
                delete(record: recordToDelete)
            }
        } else {
            // 체크 안 된 상태: 새 레코드 생성
            routineStore.createRoutineRecord(
                for: item.routine,
                timestamp: item.time,
                context: context
            )
        }
    }
}
