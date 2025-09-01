import Foundation
import SwiftData

/// 앱의 SwiftData 스택을 설정하고 관리하는 싱글턴 클래스임.
///
/// 이 컨트롤러는 앱에서 사용되는 모든 SwiftData 모델을 포함하는 `Schema`를 정의하고,
/// 이를 기반으로 앱의 메인 `ModelContainer`를 생성함.
class DataController {
  
  /// 앱 전역에서 `DataController`에 접근하기 위한 공유 싱글턴 인스턴스임.
  static let shared = DataController()
  
  /// 앱의 데이터를 관리하는 메인 `ModelContainer`임.
  let container: ModelContainer
  
  /// `DataController`의 private 초기화 구문임.
  ///
  /// 이 메서드는 앱의 모든 모델을 포함하는 `Schema`를 설정하고,
  /// 영구 저장소를 사용하는 `ModelContainer`를 생성함.
  /// 컨테이너 생성에 실패하면 `fatalError`를 발생시켜 즉시 문제를 인지할 수 있도록 함.
  private init() {
    let schema = Schema([
      // 영양소
      Nutrient.self,
      NutrientRecommendation.self,
      Scrap.self,
      
      // 사용자 정보
      User.self,
      UserProfile.self,
      UserStatus.self,
      UserExtraInfo.self,
      UserLifeStyle.self,
      ExtraInfo.self, // 추가정보(질병, 알러지 등)
      Setting.self,
      
      // 루틴
      Routine.self,
      RoutineTime.self,
      RoutineRecord.self,
      
      // 식단
      Meal.self,
      Food.self,
    ])
    
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    
    do {
      container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
}
