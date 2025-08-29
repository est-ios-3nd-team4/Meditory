//
//  String+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/13/25.
//

import Foundation

extension String {
  static let separatorCommaSpace = ", "
  
  /// "HH:mm" -> 오늘 날짜의 Date (시/분만 반영)
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

  /// "오전/오후 h:mm" (자체가 "HH:mm"일 때만 적용, 아니면 "식사 안함")
  func prettyKRFromHHmm() -> String {
    guard let d = toDateFromHHmm() else { return "식사 안함" }
    return d.timeFormatter
  }
  
  /// 받침 여부에 따라 '을/를' 조사 반환
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
