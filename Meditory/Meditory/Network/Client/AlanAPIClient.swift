//
//  AlanAPIClient.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// Alan API와 통신을 담당하는 클라이언트
final class AlanAPIClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  /// 주어진 content를 기반으로 Alan API에 요청을 보낸 후 응답 문자열을 반환
  /// - Parameter content: API에 전달할 프롬프트 문자열
  /// - Returns: API 응답으로 받은 content(String)
  /// - Throws: 네트워크 에러, 디코딩 에러 등
  func request(content: String) async throws -> String {
    let endpoint = AlanAPIEndpoint.question(content: content)
    let request = endpoint.makeURLRequest()
    
    print("✅ 요청", Date.now)
    
    let data: AlanResponse = try await NetworkService.shared.request(with: request, session: session)
    let response = data.content
    
    print("✅ 응답", Date.now)
    dump(response)
    
    return response
  }
}
