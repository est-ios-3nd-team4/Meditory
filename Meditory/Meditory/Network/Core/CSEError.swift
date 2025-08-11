//
//  CSEError.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/11/25.
//

import Foundation

enum CSEError: Error, LocalizedError {
  case missingKeyOrCX
  case badURL
  case http(status: Int, body: String)
  case decode(Error)

  var errorDescription: String? {
    switch self {
    case .missingKeyOrCX:
      return "API 키 또는 CX가 없습니다."
    case .badURL:
      return "요청 URL 생성에 실패했습니다."
    case .http(let s, let body):
      return "HTTP \(s): \(body)"
    case .decode(let e):
      return "응답 파싱 실패: \(e.localizedDescription)"
    }
  }
}
