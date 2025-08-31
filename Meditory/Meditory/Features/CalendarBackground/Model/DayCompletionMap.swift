//
//  DayCompletionMap.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import Foundation

/// 특정 날짜별 복용 완료율(달성률)을 저장하는 맵 타입입니다.
/// - Key: `Date` (자정 기준 날짜)
/// - Value: 완료율(`Double`, 0.0 ~ 1.0)
///
/// 예시:
/// ```swift
/// let map: DayCompletionMap = [
///   Calendar.current.startOfDay(for: Date()): 0.75
/// ]
/// ```
public typealias DayCompletionMap = [Date: Double]

extension DayCompletionMap {
  /// 특정 날짜의 완료율(progress)을 반환합니다.
  /// - Parameters:
  ///   - date: 조회할 날짜
  ///   - calendar: 비교에 사용할 캘린더 (기본값: `.current`)
  /// - Returns: 완료율(Double). 값이 없거나 범위를 벗어나면 0~1 범위로 클램핑합니다.
  ///
  /// 예시:
  /// ```swift
  /// let progress = map.progress(for: Date())
  /// print(progress) // 0.0 ~ 1.0
  /// ```
  public func progress(for date: Date, calendar: Calendar = .current) -> Double {
    if let (_, value) = first(where: { calendar.isDate($0.key, inSameDayAs: date) }) {
      return Swift.min(Swift.max(value, 0), 1)
    }
    return 0
  }
}
