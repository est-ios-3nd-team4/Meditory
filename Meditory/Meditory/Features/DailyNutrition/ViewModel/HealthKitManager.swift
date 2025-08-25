//
//  HealthKitManager.swift
//  Meditory
//
//  Created by 이치훈 on 8/19/25.
//

import HealthKit
import SwiftUI

@MainActor
class HealthKitManager: ObservableObject {
  private let healthStore = HKHealthStore()
  
  @Published var todaySteps: Int = 0
  @Published var isAuthorized = false
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  var isHealthKitAvailable: Bool {
    HKHealthStore.isHealthDataAvailable()
  }
  
  /// 현재 HealthKit 권한 상태를 확인
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
      try await Task.sleep(nanoseconds: 500_000_000)
      
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
    
  // 오늘 하루 걸음 수 데이터를 가져옴
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
  
  /// fetchTodaySteps 랩핑
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

enum HealthKitError: LocalizedError {
  case notAvailable
  case authorizationFailed
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

enum ActivityLevel: CaseIterable {
  case sedentary            // < 3,000 걸음
  case lightlyActive       // 3,000 - 7,000 걸음
  case moderatelyActive   // 7,000 - 10,000 걸음
  case veryActive        // 10,000 - 12,500 걸음
  case extremelyActive  // > 12,500 걸음
  
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
