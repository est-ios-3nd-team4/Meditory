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
  let userStore = UserStore()

  init() {
    //        FirebaseApp.configure()
  }
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,

      //User 정보
      User.self,
      UserProfile.self,
      UserStatus.self,
      UserAllergy.self,
      UserExtraInfo.self,
      // 추가정보(질병 알러지 등)
      ExtraInfo.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      MainTabView()
      //      UserTestView()//          SwiftData 테스트용
        .onAppear {
          // ExtraInfo 의 데이터는 변경이 일어나기 쉬우므로 앱을 켤때마다 기존 데이터 날리고 스크립트로 새로인서트하기 위한 코드
          let context = ModelContext(sharedModelContainer)
          userStore.resetExtraInfos(context: context)
        }
        .modelContainer(sharedModelContainer)
    }
  }
}
