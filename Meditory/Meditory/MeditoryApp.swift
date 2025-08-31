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

/// Meditory 앱의 진입점(`@main`).
///
/// - 역할:
///   - 앱 실행 시 온보딩/스플래시/메인 화면 전환을 관리합니다.
///   - SwiftData의 `DataController`와 사용자/영양제 관련 Store, ViewModel을 초기화하여 환경에 주입합니다.
///   - 알림 권한을 확인하고, 시스템/앱 설정에 따라 루틴 알림을 스케줄링하거나 취소합니다.
///   - iOS 14+에서 필요한 `UIApplicationDelegate` 연결(AppDelegate)을 포함합니다.
@main
struct MeditoryApp: App {
  /// `UserStore`를 환경에서 불러옵니다.
  @Environment(\.userStore) private var userStore

  /// UIKit `AppDelegate`를 SwiftUI 앱 구조에 어댑터로 연결합니다.
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  /// 영양 관리 메인 ViewModel (NutritionMainViewModel).
    /// - SwiftData의 mainContext를 주입하여 초기화됩니다.
  @StateObject private var nutritionViewModel: NutritionMainViewModel = {
    let context = DataController.shared.container.mainContext
    return NutritionMainViewModel(modelContext: context)
  }()

  init() {
    //        FirebaseApp.configure()
  }

  /// 앱 최초 실행 여부(온보딩 필요 여부).
  @AppStorage("needOnboarding") private var needOnboarding: Bool = true

  /// 새 온보딩 화면을 이미 본 적이 있는지 여부(1회).
  @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

  /// 앱 내에서 표시할 스플래시 화면의 활성 상태.
  @State private var showSplash: Bool = true

  var body: some Scene {
    WindowGroup {
      ZStack {
        Group{
          // 공통 전환 애니메이션 정의
          let onboardingTransition =
               AnyTransition.asymmetric(
                 insertion: .opacity
                   .combined(with: .move(edge: .trailing))
                   .combined(with: .scale(scale: 0.98, anchor: .center)),
                 removal: .opacity
               )

          // 1. 아직 새 온보딩을 보지 않았다면 → IntroduceOnboardingView 표시
          if !hasSeenOnboarding {
                IntroduceOnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                  .transition(onboardingTransition)
                  .zIndex(2)
              }

          // 2. 새 온보딩은 봤지만 기존 온보딩이 필요한 경우(사용자가 개인정보를 입력 안 한 경우) → OnboardingView 표시
          if hasSeenOnboarding && needOnboarding {
            OnboardingView(userStore: userStore) {
              withAnimation(.easeInOut(duration: 0.35)) {
                needOnboarding = false
              }
            }
            .transition(onboardingTransition)
            .zIndex(1)
          }

          // 3. 온보딩을 모두 완료한 경우 → MainTabView 표시
          if hasSeenOnboarding && !needOnboarding {
            MainTabView()
              .modelContainer(DataController.shared.container)
              .environment(\.userStore, UserStore.shared)
              .environmentObject(nutritionViewModel)
              .task {
                // 최초 실행 시 알림 권한 및 설정 확인
                let hasSetting = await SettingStore.shared.fetchSetting() != nil

                if !hasSetting {
                  // 알림 권한 요청
                  let granted = await NotificationManager.shared.requestAuthorization()
                  await SettingStore.shared.updateNotificationSetting(granted)

                  if granted {
                    await RoutineNotificationScheduler().scheduleAll()
                  } else {
                    NotificationManager.shared.cancelAllIncludingDelivered()
                  }

                  return
                }

                // 기존 설정이 있다면 상태 확인 후 알림 재스케줄 or 취소
                let isOn = await SettingStore.shared.fetchSetting()?.isNotificationOn ?? false
                let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
                let systemGranted = (status == .authorized || status == .provisional || status == .ephemeral)

                if isOn && systemGranted {
                  await RoutineNotificationScheduler().scheduleAll()
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
      // 온보딩 상태 변화에 따라 전환 애니메이션 적용
      .animation(.easeInOut(duration: 0.35), value: needOnboarding)
      .animation(.easeInOut(duration: 0.35), value: hasSeenOnboarding)
      // 앱 실행 시 스플래시 오버레이
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

  /// 앱 델리게이트 구현체.
  /// - 역할:
  ///   - 알림 센터(delegate) 연결
  ///   - 포그라운드 알림 표시 방식 제어 (배너/사운드/리스트)
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
