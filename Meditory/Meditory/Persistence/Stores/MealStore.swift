import Foundation
import SwiftData

/// Meal 데이터를 SwiftData에 저장/조회/삭제하는 스토어 클래스
final class MealStore {

    /// Meal 1개를 추가하고 저장
    func addMeal(_ meal: Meal, context: ModelContext) {
        context.insert(meal)      // 컨텍스트에 Meal 엔티티 삽입
        try? context.save()       // DB에 반영
    }

    /// 모든 Meal 목록을 날짜 기준으로 정렬하여 조회
    func fetchAllMeals(context: ModelContext) -> [Meal] {
        // date 프로퍼티 기준 오름차순 정렬
        let descriptor = FetchDescriptor<Meal>(sortBy: [SortDescriptor(\.date)])
        // 페치 시도, 실패하면 빈 배열 반환
        return (try? context.fetch(descriptor)) ?? []
    }

    /// 특정 Meal 1개를 삭제
    func deleteMeal(_ meal: Meal, context: ModelContext) {
        context.delete(meal)      // 해당 Meal 삭제
        try? context.save()       // DB에 반영
    }

    /// 모든 Meal을 삭제
    func deleteAllMeals(context: ModelContext) {
        let all = fetchAllMeals(context: context) // 전체 Meal 가져오기
        all.forEach { context.delete($0) }        // 하나씩 삭제
        try? context.save()                       // DB에 반영
    }
}
