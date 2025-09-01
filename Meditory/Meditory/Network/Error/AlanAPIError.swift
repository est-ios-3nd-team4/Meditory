//
//  AlanAPIError.swift
//  Meditory
//
//  Created by 홍승아 on 8/31/25.
//

import Foundation

enum AlanAPIError: Error {
  case network(Error)
  case decoding(Error)
  case cancelld
  
  var title: String {
    switch self {
    case .network:
      return "네트워크 오류"
    case .decoding:
      return "데이터 처리 오류"
    default: return ""
    }
  }
  
  var message: String {
    switch self {
    case .network:
      return "인터넷 연결에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
    case .decoding:
      return "데이터를 불러오는 중 문제가 발생했습니다. 다시 시도해주세요."
    default: return ""
    }
  }
}
