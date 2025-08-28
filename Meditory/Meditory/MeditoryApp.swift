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
  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false   // 새 온보딩 노출 여부(1회)
  @State private var showSplash: Bool = true                                     // 앱 내 스플래시 오버레이

  var body: some Scene {
    WindowGroup {
      ZStack {
        Group{
          let onboardingTransition =
               AnyTransition.asymmetric(
                 insertion: .opacity
                   .combined(with: .move(edge: .trailing))
                   .combined(with: .scale(scale: 0.98, anchor: .center)),
                 removal: .opacity
               )
          if !hasSeenOnboarding {
                IntroduceOnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                  .transition(onboardingTransition)
                  .zIndex(2)
              }

          if hasSeenOnboarding && needOnboarding {
            OnboardingView(userStore: userStore) {
              withAnimation(.easeInOut(duration: 0.35)) {
                needOnboarding = false
              }
            }
            .transition(onboardingTransition)
            .zIndex(1)
          }

          if hasSeenOnboarding && !needOnboarding {
            MainTabView()
              .modelContainer(DataController.shared.container)
              .environment(\.userStore, UserStore.shared)
              .environmentObject(nutritionViewModel)
            //            .task { await UserStore.shared.resetExtraInfos() } // ExtraInfo 의 데이터는 변경이 일어나기 쉬우므로 앱을 켤때마다 기존 데이터 날리고 스크립트로 새로인서트하기 위한 코드
              .task {
                let context = DataController.shared.container.mainContext

                // 최초 실행이면 권한 1회 요청
                if await SettingStore.shared.fetchSetting() == nil {
                  let granted = await NotificationManager.shared.requestAuthorization()
                  await SettingStore.shared.updateNotificationSetting(granted)
                }

                // 저장된 앱 토글 값
                let isOn = await SettingStore.shared.fetchSetting()?.isNotificationOn ?? false

                // 시스템 권한
                let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
                let systemGranted = (status == .authorized || status == .provisional || status == .ephemeral)

                if isOn && systemGranted {
                  // 스케줄 가능 → 전체 루틴 스케줄
                  let scheduler = RoutineNotificationScheduler()
                  await scheduler.scheduleAll(modelContext: context)
                } else {
                  // 예약 정리 및 저장값 보정(토글은 ON인데 권한 거부 상태였다면 OFF로)
                  NotificationManager.shared.cancelAllIncludingDelivered()
                  if isOn && !systemGranted {
                    await SettingStore.shared.updateNotificationSetting(false)
                  }
                }
              }
          }
        }
      }
      // 상태 변화에 따라 전체 전환 페이드
      .animation(.easeInOut(duration: 0.35), value: needOnboarding)
      .animation(.easeInOut(duration: 0.35), value: hasSeenOnboarding)
      // 앱 내 스플래시를 최상단에 오버레이
      .overlay {
        if showSplash {
          SplashView() {
            withAnimation(.easeOut(duration: 0.25)) {
              showSplash = false
            }
          }
          .transition(.asymmetric(insertion: .identity, removal: .opacity))
          .zIndex(99)
          .allowsHitTesting(true)
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
