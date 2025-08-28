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
  
  var time: Date {
    Date.makeTime(hour: hour, minute: minute)
  }
  
  var timeString: String {
    time.timeFormatter
  }
  
  var relativeTimeDescription: String {
    let minutes = abs(offsetMinutes)
    switch relativeTo {
    case "아침", "점심", "저녁":
      if offsetMinutes == 0 {
        return "식사 직후"
      }
      return offsetMinutes < 0 ? "식전 \(minutes)분" : "식후 \(minutes)분"

    case "기상":
      if offsetMinutes == 0 {
        return "기상 직후"
      }
      return offsetMinutes > 0 ? "직후 \(minutes)분" : "직전 \(minutes)분"

    case "취침":
      if offsetMinutes == 0 {
        return "취침 직전"
      }
      return offsetMinutes > 0 ? "직후 \(minutes)분" : "직전 \(minutes)분"

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
  
  var routineTimes: [RoutineTime] {
    times.map { doseTime in
      RoutineTime(
        time: doseTime.time,
        intakeTiming: doseTime.relativeTo,
        intakeOffsetMinutes: doseTime.offsetMinutes,
        pillsPerDose: doseTime.pillsPerDose
      )
    }
  }
}

/// LLM 응답 DTO
struct SupplementDTO: Codable {
  var schedule: DoseSchedule // 추천 일정
  var usage: [String] // 복용법
  var precautions: [String] // 복용 시 주의 사항
}

extension SupplementDTO {
  static var mock: SupplementDTO {
    SupplementDTO(
      schedule: DoseSchedule(
        cycleType: .weekday,
        times: [
          DoseTime(
            hour: 8,
            minute: 30,
            relativeTo: "아침",
            offsetMinutes: 0,
            pillsPerDose: 2
          ),
          DoseTime(
            hour: 22,
            minute: 0,
            relativeTo: "취침",
            offsetMinutes: -30,
            pillsPerDose: 1
          )
        ],
        weekdays: [1, 3, 5],
        intervalDays: nil
      ),
      usage: [
        "물과 함께 복용하세요.",
        "하루 최대 2정을 초과하지 마세요."
      ],
      precautions: [
        "임산부, 수유부는 복용 전 전문가와 상담하세요.",
        "다른 약물과 함께 복용 시 상호작용에 주의하세요."
      ]
    )
  }
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
