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
  
  // 권한 요청
  func requestAuthorization() async throws {
    guard isHealthKitAvailable else {
      throw HealthKitError.notAvailable
    }
    
    guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
      throw HealthKitError.dataTypeNotAvailable
    }
    
    let typesToRead: Set<HKObjectType> = [stepType]
    let typesToShare: Set<HKSampleType> = []
    
    do {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
          if let error = error {
            continuation.resume(throwing: error)
          } else if success {
            continuation.resume()
          } else {
            continuation.resume(throwing: HealthKitError.authorizationFailed)
          }
        }
      }
      
      isAuthorized = true
    } catch {
      isAuthorized = false
      throw error
    }
  }
  
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
  
  func loadTodatSteps() async {
    isLoading = true
    errorMessage = nil
    
    do {
      if !isAuthorized {
        try await requestAuthorization()
      }
      
      let steps = try await fetchTodaySteps()
      todaySteps = steps
    } catch {
      errorMessage = error.localizedDescription
      print("걸음 수 로드 실패: \(error)")
    }
    
    isLoading = false
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
