//
//  APIKey.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

enum APIKey: String {
  case alan = "AlanAPIKey"

  var value: String? {
    Bundle.main.object(forInfoDictionaryKey: self.rawValue) as? String
  }
}

enum GoogleKey {
  static var apiKey: String { value("googleCSEKey") }

  static var cx: String { value("googleCSE_CX") }

  private static func value(_ key: String) -> String {
    (Bundle.main.object(forInfoDictionaryKey: key) as? String) ?? ""
  }
}
