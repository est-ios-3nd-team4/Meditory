//
//  PIIRedactor.swift
//  Meditory
//
//  Created by 홍승아 on 8/30/25.
//

import Foundation
import NaturalLanguage

struct PIIRedactor {
  
  /// 텍스트 내 PII(개인 식별 정보)를 마스킹 처리
  static func redactPII(in text: String) -> String {
    var redacted = text
    let mask = ""
    
    let patterns: [String: String] = [
      // 이메일
      "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}" : mask,
      // 전화번호 (예: 010-1234-5678)
      "\\b\\d{2,3}[- .]?\\d{3,4}[- .]?\\d{4}\\b" : mask,
      // 주민등록번호 (예: 900101-1234567)
      "\\b\\d{6}[- ]?\\d{7}\\b" : mask,
      // 신용카드 번호
      "(?:\\d[ -]*?){13,16}" : mask,
      // 여권번호
      "[A-Z]{1}[0-9]{7,8}" : mask,
      // 운전면허 번호
      "\\b\\d{2,6}-\\d{2}-\\d{6}\\b" : mask,
      // 주소 (도 / 특별자치도 / 특별자치시 / 특별시 / 광역시 + 시/군/구 + 동/로/길/번길 + 번지)
      "([가-힣]{2,}(도|특별자치도|특별자치시|특별시|광역시))(\\s?[가-힣0-9\\-]+(시|군|구))+?\\s?[가-힣0-9\\-]+(동|로|길|번길)\\s?[0-9\\-]+" : mask
    ]
    
    for (pattern, replacement) in patterns {
      if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
        let range = NSRange(redacted.startIndex..<redacted.endIndex, in: redacted)
        redacted = regex.stringByReplacingMatches(
          in: redacted,
          options: [],
          range: range,
          withTemplate: replacement
        )
      }
    }
    
    return redacted
  }
}
