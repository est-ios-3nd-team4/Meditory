import Foundation
import SwiftData

class DataController {
    static let shared = DataController()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
          Item.self,
          Nutrient.self,
          Scrap.self,
          NutrientRecommendation.self,

          //User 정보
          User.self,
          UserProfile.self,
          UserStatus.self,
          UserExtraInfo.self,

          ExtraInfo.self, // 추가정보(질병 알러지 등)
          Setting.self,

          // Routine
          Routine.self,
          RoutineTime.self,
          RoutineRecord.self,

          // Nutrient
          Nutrient.self,
          NutrientRecommendation.self,
          Scrap.self,

          // 식단
          Meal.self,
          Food.self,
          Macro.self,
        ])
        
      let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
