//
//  SupplementDoseSchedule.swift
//  Meditory
//
//  Created by 홍승아 on 8/14/25.
//

import Foundation

/// 영양제 복용 스케줄(시간 + 1회 복용량)을 나타내는 구조체.
///
/// 사용자가 설정한 복용 시간을 `Date`로 보관하고,
/// 1회 복용 알약 수(`pillsPerDose`)를 함께 관리합니다.
/// 이 모델은 `RoutineTime`으로 변환되어 실제 저장 로직에서 활용됩니다.
struct SupplementDoseSchedule {
  var time: Date
  var pillsPerDose: Int
  
  var hour: Int {
    time.hour
  }
  
  var minute: Int {
    time.minute
  }
  
  var doseString: String {
    "\(pillsPerDose)정"
  }
  
  var routineTime: RoutineTime {
    RoutineTime(time: .makeTime(hour: hour, minute: minute), pillsPerDose: pillsPerDose)
  }
}
