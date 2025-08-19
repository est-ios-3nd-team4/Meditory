//
//  SupplementDTO.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation

/// 요일별(1) / 주기별(2)
extension SupplementScheduleType: Codable {}

enum TimeSpec: Codable, Equatable {
  case absolute(hour: Int, minute: Int)
  case relative(relativeTo: String, offsetMinutes: Int)

  private struct AbsDTO: Codable {
    let hour: Int
    let minute: Int
  }

  private struct RelDTO: Codable {
    let relativeTo: String
    let offsetMinutes: Int
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let abs = try? container.decode(AbsDTO.self) {
      self = .absolute(hour: abs.hour, minute: abs.minute)
      return
    }
    if let rel = try? container.decode(RelDTO.self) {
      self = .relative(relativeTo: rel.relativeTo, offsetMinutes: rel.offsetMinutes)
      return
    }
    throw DecodingError.dataCorruptedError(in: container, debugDescription: "TimeSpec 형식 오류")
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case let .absolute(h, m):
      try container.encode(AbsDTO(hour: h, minute: m))
    case let .relative(ref, off):
      try container.encode(RelDTO(relativeTo: ref, offsetMinutes: off))
    }
  }
}

/// 복용 스케줄
struct DoseSchedule: Codable {
  var cycleType: SupplementScheduleType // 요일별, 주기별
  var times: [TimeSpec]
  /// cycleType == .weekdays(요일 인덱스: 일=0 ~ 토=6)
  var weekdays: [Int]?
  /// cycleType == .interval  (예: 2 → 2일 간격)
  var intervalDays: Int?
}

/// LLM 응답 DTO
struct SupplementDTO: Codable {
  var type: Int // 1=영양제, 2=약
  var pillsPerDose: Int // 몇 정
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
