//
//  SchedulePickerType.swift
//  Meditory
//
//  Created by 홍승아 on 8/6/25.
//

import Foundation

/// 복용 스케줄 선택 시 표시되는 Picker Sheet 종류.
///
/// 이 타입은 영양제 복용 일정을 설정할 때
/// 사용자가 선택할 수 있는 항목(월, 일, 주기, 요일, 시간)을 나타냅니다.
enum SchedulePickerType: Identifiable, CaseIterable {
  case month
  case day
  case duration
  case weekday
  case time
  
  var id: Int {
    switch self {
    case .month: return 0
    case .day: return 1
    case .duration: return 2
    case .weekday: return 3
    case .time: return 4
    }
  }
  
  var title: String {
    switch self {
    case .month:
      return "시작하는 달"
    case .day:
      return "시작하는 날"
    case .duration:
      return "복용 주기"
    case .weekday:
      return "복용 요일"
    case .time:
      return "복용 시간"
    }
  }
}
