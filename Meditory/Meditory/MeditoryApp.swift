//
//  MeditoryApp.swift
//  Meditory
//
//  Created by 윤혜주 on 7/30/25.
//

import SwiftUI
import SwiftData
//import FirebaseCore

@main
struct MeditoryApp: App {
  
  @Environment(\.userStore) private var userStore // TODO: Onboarding 에 UserStore 재적용하면서 삭제 예정
  
  
  init() {
    //        FirebaseApp.configure()
  }

  var sharedModelContainer: ModelContainer = {
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
      //Macro.self,

    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")

    }
  }()


  // MARK: 기존 schema, context 설정 등은 DataController 로 이동함
  
  @AppStorage("needOnboarding") private var needOnboarding: Bool = true
  
  var body: some Scene {
    WindowGroup {
      
      Group{
        if needOnboarding {
          OnboardingView(userStore: userStore) {
            needOnboarding = false
          }
        } else {
          MainTabView()
            .modelContainer(DataController.shared.container)
            .environment(\.userStore, UserStore.shared)
//            .task { await UserStore.shared.resetExtraInfos() } // ExtraInfo 의 데이터는 변경이 일어나기 쉬우므로 앱을 켤때마다 기존 데이터 날리고 스크립트로 새로인서트하기 위한 코드
        }
      }
    }
  }
}
