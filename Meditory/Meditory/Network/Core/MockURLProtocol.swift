//
//  MockURLProtocol.swift
//  Meditory
//
//  Created by 홍승아 on 8/3/25.
//

import Foundation

/// `URLSession`을 테스트할 때 네트워크 요청을 가짜로 처리하는 커스텀 `URLProtocol`.
/// - 실제 네트워크 호출을 막고, 미리 정의한 응답(`Data`, `HTTPURLResponse`, `Error`)을 반환합니다.
/// - `XCTest` 단위 테스트에서 서버와 독립적으로 네트워크 로직을 검증할 때 사용합니다.
final class MockURLProtocol: URLProtocol {
  
  /// 테스트에서 요청을 가로채 응답을 반환하는 핸들러
  /// - Parameter request: 가로챈 URL 요청
  /// - Returns: `(Data?, HTTPURLResponse?, Error?)`
  static var requestHandler: ((URLRequest) throws -> (Data?, HTTPURLResponse?, Error?))?
  
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  
  override func startLoading() {
    guard let handler = MockURLProtocol.requestHandler else {
      fatalError("Handler is not set.")
    }
    
    do {
      let (data, response, error) = try handler(request)
      if let response = response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let data = data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let error = error {
        client?.urlProtocol(self, didFailWithError: error)
      } else {
        client?.urlProtocolDidFinishLoading(self)
      }
    } catch {
      client?.urlProtocol(self, didFailWithError: error)
    }
  }
  
  override func stopLoading() { }
}
