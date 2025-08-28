//
//  AlanAPIClient.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

final class AlanAPIClient {
  private let session: URLSession
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
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
