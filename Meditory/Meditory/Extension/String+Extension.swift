//
//  String+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//

import Foundation

/// `String` 확장
/// - 앱에서 자주 사용하는 문자열 변환/처리 유틸리티를 제공합니다.
/// - 시간 문자열(`HH:mm`)을 `Date`로 변환하거나, 한국어 조사 처리 등에 활용됩니다.
extension String {
  /// 문자열 분리 구분자: `", "` (쉼표+공백)
  static let separatorCommaSpace = ", "

  /// `"HH:mm"` 형식의 문자열을 오늘 날짜 기준 `Date`로 변환합니다.
  /// - Parameters:
  ///   - calendar: 변환 시 사용할 `Calendar` (기본값: `.current`)
  /// - Returns: 시/분 정보가 반영된 오늘 날짜의 `Date`, 형식이 올바르지 않으면 `nil`
  ///
  /// - Example:
  ///   ```swift
  ///   let date = "09:30".toDateFromHHmm()
  ///   print(date) // 오늘 날짜의 오전 9시 30분
  ///   ```
  func toDateFromHHmm(calendar: Calendar = .current) -> Date? {
    let parts = split(separator: ":")
    guard parts.count == 2,
          let h = Int(parts[0]),
          let m = Int(parts[1]),
          (0..<24).contains(h),
          (0..<60).contains(m) else { return nil }
    var dc = calendar.dateComponents([.year, .month, .day], from: Date())
    dc.hour = h
    dc.minute = m
    dc.second = 0
    return calendar.date(from: dc)
  }

  /// `"HH:mm"` 형식의 문자열을 `"오전/오후 h:mm"` 형식으로 변환합니다.
  /// - 내부적으로 `Date`로 변환 후 `Date.timeFormatter`를 사용합니다.
  /// - 변환 실패 시 `"식사 안함"`을 반환합니다.
  ///
  /// - Example:
  ///   ```swift
  ///   print("09:30".prettyKRFromHHmm()) // "오전 9:30"
  ///   print("invalid".prettyKRFromHHmm()) // "식사 안함"
  ///   ```
  func prettyKRFromHHmm() -> String {
    guard let d = toDateFromHHmm() else { return "식사 안함" }
    return d.timeFormatter
  }

  /// 문자열의 마지막 글자를 기준으로 받침 여부를 판별해 한국어 조사 **"을/를"**을 반환합니다.
  /// - 한글 음절 범위(`가~힣`)를 검사하여 종성(받침)이 있으면 `"을"`, 없으면 `"를"`을 반환합니다.
  /// - 한글이 아닌 경우 기본적으로 `"를"`을 반환합니다.
  ///
  /// - Example:
  ///   ```swift
  ///   print("사과".eulReul()) // "를"
  ///   print("밥".eulReul())   // "을"
  ///   ```
  func eulReul() -> String {
    guard let last = self.unicodeScalars.last else { return "를" }
    let scalar = last.value

    // 한글 범위(가~힣)인지 확인
    if (0xAC00...0xD7A3).contains(scalar) {
      let base = scalar - 0xAC00
      let jong = base % 28   // 종성(받침) 여부
      return jong == 0 ? "를" : "을"
    }
    // 한글이 아닌 경우 기본 '를'
    return "를"
  }
}
