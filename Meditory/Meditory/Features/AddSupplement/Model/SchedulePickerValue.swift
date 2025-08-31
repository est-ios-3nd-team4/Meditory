//
//  SchedulePickerValue.swift
//  Meditory
//
//  Created by 홍승아 on 8/8/25.
//

import Foundation

/// 복용 스케줄 피커에서 선택된 값을 나타내는 열거형.
///
/// `SchedulePickerType`과 매칭되며, 각 케이스는
/// 해당 피커에서 선택된 실제 데이터를 담습니다.
///
/// - `month(Int)`: 시작하는 달 (1~12)
/// - `day(Int)`: 시작하는 일 (1~31)
/// - `duration(Int)`: 복용 주기 (일 단위)
/// - `weekday([Weekday: Bool])`: 요일 선택 결과.
///   각 요일(`Weekday`)이 선택되었는지 여부를 Bool 값으로 저장.
/// - `time(SupplementDoseSchedule)`: 복용 시간 및 복용량 스케줄
enum SchedulePickerValue {
  case month(Int)
  case day(Int)
  case duration(Int)
  case weekday([Weekday: Bool])
  case time(SupplementDoseSchedule)
}
