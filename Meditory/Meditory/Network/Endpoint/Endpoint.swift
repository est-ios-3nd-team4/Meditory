//
//  Endpoint.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// 네트워크 요청을 생성하기 위한 기본 인터페이스.
protocol Endpoint {
  func makeURLRequest() -> URLRequest?
}
