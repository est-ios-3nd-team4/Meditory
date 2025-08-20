//
//  DayCompletionMap.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import Foundation

/// 날짜별 완료율(0.0 ... 1.0)
public typealias DayCompletionMap = [Date: Double]

extension DayCompletionMap {
  public func progress(for date: Date, calendar: Calendar = .current) -> Double {
    if let (_, value) = first(where: { calendar.isDate($0.key, inSameDayAs: date) }) {
      return Swift.min(Swift.max(value, 0), 1)
    }
    return 0
  }
}


