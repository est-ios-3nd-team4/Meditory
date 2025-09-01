//
//  APIKey.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// 앱에서 사용하는 API Key를 Info.plist에서 안전하게 불러오기 위한 enum
enum APIKey: String {
  case alan = "AlanAPIKey"
  
  var value: String? {
    Bundle.main.object(forInfoDictionaryKey: self.rawValue) as? String
  }
}

/// Google API 관련 키를 관리하는 enum
enum GoogleKey {
  static var apiKey: String { value("googleCSEKey") }
  
  static var cx: String { value("googleCSE_CX") }
  
  private static func value(_ key: String) -> String {
    let raw = (Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    return raw.hasPrefix("$(") ? "" : raw
  }
}
