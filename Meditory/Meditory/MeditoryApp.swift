//
//  MeditoryApp.swift
//  Meditory
//
//  Created by 윤혜주 on 7/30/25.
//

import SwiftUI
import SwiftData
//import FirebaseCore
import UserNotifications

@main
struct MeditoryApp: App {

  @Environment(\.userStore) private var userStore // TODO: Onboarding 에 UserStore 재적용하면서 삭제 예정
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var nutritionViewModel: NutritionMainViewModel = {
    let context = DataController.shared.container.mainContext
    return NutritionMainViewModel(modelContext: context)
  }()

  init() {
    //        FirebaseApp.configure()
  }
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
            .environmentObject(nutritionViewModel)
          //            .task { await UserStore.shared.resetExtraInfos() } // ExtraInfo 의 데이터는 변경이 일어나기 쉬우므로 앱을 켤때마다 기존 데이터 날리고 스크립트로 새로인서트하기 위한 코드
            .onChange(of: scenePhase) { _, phase in
              if phase == .active {
                Task {
                  let context = DataController.shared.container.mainContext
                  let isOn = await SettingStore.shared.fetchSetting()?.isNotificationOn ?? false
                  let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
                  let systemGranted = (status == .authorized || status == .provisional || status == .ephemeral)
                  
                  if isOn && systemGranted {
                    await RoutineNotificationScheduler().scheduleAll(modelContext: context)
                  } else {
                    NotificationManager.shared.cancelAllIncludingDelivered()
                    if isOn && !systemGranted {
                      await SettingStore.shared.updateNotificationSetting(false)
                    }
                  }
                }
              }
            }
        }
      }
    }
  }

  final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
      }

      // 포그라운드에서도 배너/사운드
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification,
                                  withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
      }
    }
}
