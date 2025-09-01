//
//  NetworkError.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// 네트워크 요청 처리 중 발생할 수 있는 오류를 정의한 열거형
enum NetworkError: Error {
  case invalidRequest
  case unprocessableEntity
}
