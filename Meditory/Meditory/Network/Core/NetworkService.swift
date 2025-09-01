//
//  NetworkService.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// 네트워크 요청을 처리하고 응답 데이터를 디코딩하는 서비스 클래스
final class NetworkService {
  static let shared = NetworkService()
  
  private init() { }
  
  /// 네트워크 요청을 수행하고 응답 데이터를 제네릭 타입으로 디코딩합니다.
  func request<T: Decodable>(
    with request: URLRequest?,
    session: URLSession = .shared
  ) async throws -> T {
    guard let request else { throw NetworkError.invalidRequest }
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }
    
    switch httpResponse.statusCode {
    case 200..<300:
      let decoded = try JSONDecoder().decode(T.self, from: data)
      return decoded
    case 422: throw NetworkError.unprocessableEntity
    default: throw URLError(.badServerResponse)
    }
  }
}
