//
//  SupplementScheduleType.swift
//  Meditory
//
//  Created by 홍승아 on 8/5/25.
//

import Foundation

/// 영양제 복용 스케줄 방식을 나타내는 열거형.
///
/// - `weekday`: 요일별로 복용 요일을 지정하는 방식
/// - `interval`: 시작 날짜와 주기를 설정하여 반복하는 방식
enum SupplementScheduleType: Int, CaseIterable {
  /// 요일별 복용 스케줄 (예: 월/수/금)
  case weekday = 1
  /// 주기별 복용 스케줄 (예: 3일마다 1회)
  case interval
  
  var title: String {
    switch self {
    case .weekday:
      return "요일별"
    case .interval:
      return "주기별"
    }
  }
}
