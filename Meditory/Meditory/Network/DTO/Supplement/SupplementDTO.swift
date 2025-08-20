//
//  SupplementDTO.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation

/// 요일별(1) / 주기별(2)
extension SupplementScheduleType: Codable {}

struct DoseTime: Codable, Equatable {
  /// 절대 시각 (예: 8시 30분)
  var hour: Int
  var minute: Int
  
  /// 상대 시각 (예: 아침 +30분)
  /// relativeTo=["기상","취침","아침","점심","저녁","추천(무관)"]
  var relativeTo: String
  var offsetMinutes: Int
  
  /// 1회 복용량 (정 수)
  var pillsPerDose: Int
  
  var timeString: String {
    Date.makeTime(hour: hour, minute: minute).timeFormatter
  }
  
  var relativeTimeDescription: String {
    let minutes = abs(offsetMinutes)
    switch relativeTo {
    case "아침", "점심", "저녁":
      return offsetMinutes < 0 ? "식전 \(minutes)분" : "식후 \(minutes)분"
    case "기상", "취침":
      return offsetMinutes < 0 ? "직후 \(minutes)분" : "직전 \(minutes)분"
    default:
      return ""
    }
  }
  
  var isNotNone: Bool {
    relativeTo != "추천"
  }
  
  var doseString: String {
    "\(pillsPerDose)정"
  }
}

/// 복용 스케줄
struct DoseSchedule: Codable {
  var cycleType: SupplementScheduleType // 요일별, 주기별
  var times: [DoseTime]
  /// cycleType == .weekdays(요일 인덱스: 일=0 ~ 토=6)
  var weekdays: [Int]?
  /// cycleType == .interval  (예: 2 → 2일 간격)
  var intervalDays: Int?
}

/// LLM 응답 DTO
struct SupplementDTO: Codable {
  var schedule: DoseSchedule // 추천 일정
  var usage: [String] // 복용법
  var precautions: [String] // 복용 시 주의 사항
}

enum SupplementDecoder {
  private static func jsonBody(in response: String) -> String {
    if let start = response.firstIndex(of: "{"),
       let end = response.lastIndex(of: "}") {
      return String(response[start...end])
    }
    return response.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// LLM 응답 문자열 → SupplementDTO
  static func decode(_ response: String) throws -> SupplementDTO {
    let jsonText = jsonBody(in: response)
    let jsonData = Data(jsonText.utf8)
    return try JSONDecoder().decode(SupplementDTO.self, from: jsonData)
  }
}
