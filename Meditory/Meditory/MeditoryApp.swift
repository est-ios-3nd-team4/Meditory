//
//  MeditoryApp.swift
//  Meditory
//
//  Created by 윤혜주 on 7/30/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MeditoryApp: App {
    init() {
        FirebaseApp.configure()
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

//          SwiftData 테스트용
//          UserTestView()
        }
        .modelContainer(sharedModelContainer)
    }
}
