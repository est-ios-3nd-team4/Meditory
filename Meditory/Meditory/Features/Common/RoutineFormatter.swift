//
//  RoutineFormatter.swift
//  Meditory
//
//  Created by 윤혜주 on 8/12/25.
//

import Foundation

enum RoutineFormatter {
  static func renderCycle(cycleType: Int, cycleValue: String) -> String {
    switch cycleType {
    case 1:
      // 일=0, 월=1, 화=2, 수=3, 목=4, 금=5, 토=6
      let map = ["일", "월", "화", "수", "목", "금", "토"]
      let days = cycleValue
        .split(whereSeparator: { ", ".contains($0) })
        .compactMap { Int($0) }
        .compactMap { (0...6).contains($0) ? map[$0] : nil }

      if days.count == 7 { return "매일" }
      return days.isEmpty ? "설정 없음" : days.joined(separator: "·")

    case 2:
      if let intervalDays = Int(cycleValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
        return "\(intervalDays)일 간격"
      }
      return "주기별"

    default:
      return "설정 없음"
    }
  }
}
