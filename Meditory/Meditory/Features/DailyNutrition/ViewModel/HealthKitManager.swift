//
//  HealthKitManager.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

import HealthKit
import SwiftUI

/// `HealthKitManager`
/// - iOS HealthKit 프레임워크와의 상호작용을 담당하는 메인 매니저 클래스입니다.
/// - 걸음 수 데이터 가져오기, 권한 관리, 활동 수준 계산 등의 기능을 제공합니다.
/// - `@MainActor`로 UI 업데이트를 위한 메인 스레드 안전성을 보장합니다.
///
/// ## 주요 기능
/// - **권한 관리**: HealthKit 사용 권한 요청 및 상태 확인
/// - **걸음 수 추적**: 당일 걸음 수 데이터 실시간 조회
/// - **활동 수준 계산**: 걸음 수를 기반으로 한 사용자 활동 강도 분류
/// - **에러 처리**: HealthKit 관련 에러 상황 처리 및 사용자 안내
///
/// ## 사용 예시
/// ```swift
/// let healthManager = HealthKitManager()
///
/// // 권한 요청
/// try await healthManager.requestAuthorization()
///
/// // 걸음 수 로드
/// await healthManager.loadTodaySteps()
/// print("오늘 걸음 수: \(healthManager.todaySteps)")
/// ```
@MainActor
class HealthKitManager: ObservableObject {
  /// HealthKit 데이터 스토어 인스턴스
  private let healthStore = HKHealthStore()
  
  /// 오늘 하루 걸음 수
    /// - 기본값: 100 (데이터 로드 전 표시용)
    /// - 실시간으로 업데이트되며 UI에 바인딩됨
  @Published var todaySteps: Int = 100
  
  /// HealthKit 권한 승인 여부
    /// - `true`: 걸음 수 데이터 읽기 권한 있음
    /// - `false`: 권한 없음 또는 거부됨
  @Published var isAuthorized = false
  
  /// 데이터 로딩 상태
   /// - `true`: 걸음 수 데이터를 가져오는 중
   /// - UI에서 로딩 인디케이터 표시용
  @Published var isLoading = false
  
  /// 에러 메시지
    /// - HealthKit 관련 에러 발생시 사용자에게 표시할 메시지
    /// - `nil`: 에러 없음
  @Published var errorMessage: String?
  
  /// 현재 기기에서 HealthKit 사용 가능 여부 확인
   /// - Returns: HealthKit 지원 여부 (`true`/`false`)
   /// - iPhone, Apple Watch에서는 `true`, 시뮬레이터에서는 제한적
  var isHealthKitAvailable: Bool {
    HKHealthStore.isHealthDataAvailable()
  }
  
  /// 현재 HealthKit 걸음 수 권한 상태를 확인
   /// - Returns: 권한 승인 여부 (`true`: 승인됨, `false`: 거부/미결정)
   /// - 권한 상태를 확인하여 `isAuthorized` 프로퍼티도 함께 업데이트
   /// - **주의**: 권한이 미결정 상태일 때도 `false` 반환
   ///
   /// ## 권한 상태별 동작
   /// - `.sharingAuthorized`: 권한 승인됨 → `true` 반환
   /// - `.sharingDenied`: 권한 거부됨 → `false` 반환
   /// - `.notDetermined`: 미결정 상태 → `false` 반환
  func checkCurrentAuthorizationStatus() -> Bool {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      return false
    }
    
    let status = healthStore.authorizationStatus(for: stepType)
    let authorized = (status == .sharingAuthorized) // 1 !!
    
    Task { @MainActor in
      self.isAuthorized = authorized
    }
    
    return authorized // false!!
  }
  
  /// 사용자에게 HealthKit 권한 요청 다이얼로그 표시
   /// - 걸음 수 데이터 읽기 권한을 요청합니다.
   /// - 권한 요청 후 실제 데이터 읽기 테스트를 통해 권한 상태를 검증합니다.
   /// - Throws: `HealthKitError` - HealthKit 관련 에러
   ///   - `.notAvailable`: 기기에서 HealthKit 미지원
   ///   - `.dataTypeNotAvailable`: 걸음 수 데이터 타입 접근 불가
   ///   - `.authorizationFailed`: 권한 거부 또는 데이터 읽기 실패
   ///
   /// ## 실행 과정
   /// 1. HealthKit 사용 가능 여부 확인
   /// 2. 걸음 수 데이터 타입 유효성 검사
   /// 3. 시스템 권한 요청 다이얼로그 표시
   /// 4. 실제 데이터 읽기 테스트로 권한 검증
   /// 5. `isAuthorized` 상태 업데이트
  func requestAuthorization() async throws {
    guard isHealthKitAvailable else {
      throw HealthKitError.notAvailable
    }
    
    guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
      throw HealthKitError.dataTypeNotAvailable
    }
    
    let typesToRead: Set<HKObjectType> = [stepType]
    let typesToShare: Set<HKSampleType> = []
    
    // 권한 요청
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        } else {
          continuation.resume()
        }
      }
    }
    // 실제 권한 상태를 확인
    do {
      _ = try await fetchTodaySteps()
      
      await MainActor.run {
        self.isAuthorized = true
      }
      
      print("✅ HealthKit 권한 확인됨 - 데이터 읽기 성공")
    } catch {
      await MainActor.run {
        self.isAuthorized = false
      }
      
      print("❌ HealthKit 권한 없음 - 데이터 읽기 실패: \(error)")
      throw HealthKitError.authorizationFailed
    }
  }
    
  /// 오늘 하루 걸음 수 데이터를 HealthKit에서 가져옴
   /// - Returns: 당일 총 걸음 수 (`Int`)
   /// - Throws: HealthKit 또는 데이터 조회 관련 에러
   ///
   /// ## 데이터 범위
   /// - **시작**: 오늘 자정 (00:00:00)
   /// - **종료**: 현재 시점
   /// - **집계**: 누적 합계 (`.cumulativeSum`)
   ///
   /// ## 에러 처리
   /// - 데이터가 없는 경우: `0` 반환
   /// - 권한 없음: `HealthKitError.authorizationFailed` throw
   /// - 기타 HealthKit 에러: 해당 에러 전파
  func fetchTodaySteps() async throws -> Int {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      throw HealthKitError.dataTypeNotAvailable
    }
    
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: Date())
    let predicate = HKQuery.predicateForSamples(withStart: startOfDay,
                                                end: Date(),
                                                options: .strictStartDate)
    
    return try await withCheckedThrowingContinuation { continuation in
      let query = HKStatisticsQuery(quantityType: stepType,
                                    quantitySamplePredicate: predicate,
                                    options: .cumulativeSum) { _, result, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }
        
        guard let result = result, let sum = result.sumQuantity() else {
          continuation.resume(returning: 0)
          return
        }
        
        let steps = Int(sum.doubleValue(for: HKUnit.count()))
        continuation.resume(returning: steps)
      }
      
      healthStore.execute(query)
    }
  }
  
  /// `fetchTodaySteps()`를 래핑하여 UI 상태 관리와 함께 걸음 수 로드
    /// - 로딩 상태, 에러 메시지 등을 자동으로 관리합니다.
    /// - UI에서 직접 호출하기 적합한 안전한 메서드입니다.
    ///
    /// ## 상태 업데이트
    /// - `isLoading`: 로딩 시작/완료시 자동 토글
    /// - `todaySteps`: 성공시 가져온 걸음 수로 업데이트
    /// - `errorMessage`: 에러 발생시 사용자 친화적 메시지 설정
    ///
    /// ## 에러별 메시지
    /// - **권한 거부**: "설정 → 개인정보 보호 → 건강에서 걸음 수 권한을 허용해주세요"
    /// - **데이터 없음**: 걸음 수 0으로 설정 (에러 아님)
    /// - **기타 에러**: 시스템 에러 메시지 표시
  func loadTodaySteps() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let steps = try await fetchTodaySteps()
      print("📊 가져온 걸음 수: \(steps)")
      todaySteps = steps
      
    } catch let error as HealthKitError {
      switch error {
      case .authorizationFailed:
        errorMessage = "설정 → 개인정보 보호 → 건강에서 걸음 수 권한을 허용해주세요"
      default:
        errorMessage = error.localizedDescription
      }
      print("❌ HealthKit 에러: \(error)")
      
    } catch let error as NSError {
      print("❌ 일반 에러:")
      print("   - Domain: \(error.domain)")
      print("   - Code: \(error.code)")
      print("   - Description: \(error.localizedDescription)")
      
      if error.code == 11 { // No data available
        print("ℹ️ 오늘 걸음 수 데이터 없음 - 0으로 설정")
        todaySteps = 0
      } else {
        errorMessage = error.localizedDescription
      }
    }
    
    isLoading = false
  }
  
  /// 현재 걸음 수를 기반으로 사용자의 활동 수준을 계산
    /// - Returns: `ActivityLevel` enum 값
    ///
    /// ## 활동 수준 분류
    /// - **Sedentary** (좌식): 0 ~ 2,999보
    /// - **Lightly Active** (가벼운 활동): 3,000 ~ 6,999보
    /// - **Moderately Active** (보통 활동): 7,000 ~ 9,999보
    /// - **Very Active** (활발한 활동): 10,000 ~ 12,499보
    /// - **Extremely Active** (극도로 활발): 12,500보 이상
    ///
    /// ## 사용 용도
    /// - 권장 칼로리 계산시 활동 계수(Activity Factor) 결정
    /// - BMR(기초대사율) × 활동 계수 = 일일 권장 칼로리
  func getActivityLevel() -> ActivityLevel {
    switch todaySteps {
    case 0..<3000:
        .sedentary
    case 3000..<7000:
        .lightlyActive
    case 7000..<10000:
        .moderatelyActive
    case 10000..<12500:
        .veryActive
    default:
        .extremelyActive
    }
  }
  
  /// 걸음 수 권한의 현재 상태를 콘솔에 출력 (디버깅용)
    /// - 권한 미결정, 거부, 승인 상태를 구분하여 로그 출력
    /// - 개발 및 디버깅 목적으로 사용
  func checkAuthorizationStatus() {
    guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
      print("❌ Step type을 가져올 수 없음")
      return
    }
    
    let status = healthStore.authorizationStatus(for: stepType)
    print("🔍 권한 상태: \(status.rawValue)")
    
    switch status {
    case .notDetermined:
      print("❓ 권한이 아직 결정되지 않음")
    case .sharingDenied:
      print("❌ 권한이 거부됨")
    case .sharingAuthorized:
      print("✅ 권한이 허용됨")
    @unknown default:
      print("❓ 알 수 없는 권한 상태")
    }
  }
  
}

/// `HealthKitError`
/// - HealthKit 관련 에러를 정의한 커스텀 에러 타입입니다.
/// - `LocalizedError` 프로토콜을 준수하여 사용자 친화적 에러 메시지를 제공합니다.
enum HealthKitError: LocalizedError {
  /// HealthKit을 지원하지 않는 기기 (시뮬레이터 등)
  case notAvailable
  /// 사용자가 권한을 거부했거나 데이터 읽기에 실패
  case authorizationFailed
  /// 요청한 데이터 타입(걸음 수)에 접근할 수 없음
  case dataTypeNotAvailable
  
  var errorDescription: String? {
    switch self {
    case .notAvailable:
      return "이 기기에서는 HealthKit을 사용할 수 없습니다"
    case .authorizationFailed:
      return "HealthKit 권한이 거부되었습니다"
    case .dataTypeNotAvailable:
      return "걸음 수 데이터 타입을 사용할 수 없습니다"
    }
  }
}

/// `ActivityLevel`
/// - 사용자의 일일 걸음 수를 기반으로 한 활동 강도 분류입니다.
/// - 권장 칼로리 계산시 사용되는 활동 계수(Activity Factor)를 제공합니다.
///
/// ## 분류 기준 (WHO 및 피트니스 가이드라인 기반)
/// - **Sedentary**: 주로 앉아서 생활, 운동량 부족
/// - **Lightly Active**: 가벼운 일상 활동, 산책 정도
/// - **Moderately Active**: 규칙적인 가벼운 운동
/// - **Very Active**: 활발한 운동 또는 신체 활동
/// - **Extremely Active**: 고강도 운동 또는 육체 노동
enum ActivityLevel: CaseIterable {
  case sedentary            // < 3,000 걸음
  case lightlyActive       // 3,000 - 7,000 걸음
  case moderatelyActive   // 7,000 - 10,000 걸음
  case veryActive        // 10,000 - 12,500 걸음
  case extremelyActive  // > 12,500 걸음
  
  /// 활동 수준별 칼로리 계산 계수
  /// - BMR(기초대사율)에 곱해서 일일 권장 칼로리를 계산합니다.
  /// - Returns: 활동 계수 값 (1.2 ~ 1.9)
  ///
  /// ## 계수 기준 (Harris-Benedict Equation)
  /// - **1.2**: 거의 운동하지 않음
  /// - **1.375**: 가벼운 운동 (주 1-3회)
  /// - **1.55**: 보통 운동 (주 3-5회)
  /// - **1.725**: 활발한 운동 (주 6-7회)
  /// - **1.9**: 매우 활발한 운동 (하루 2회 또는 육체 노동)
  var activityFactor: Double {
    switch self {
    case .sedentary: 1.2
    case .lightlyActive: 1.375
    case .moderatelyActive: 1.55
    case .veryActive: 1.725
    case .extremelyActive: 1.9
    }
  }
}
