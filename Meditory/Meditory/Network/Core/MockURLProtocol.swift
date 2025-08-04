//
//  MockURLProtocol.swift
//  Meditory
//
//  Created by 홍승아 on 8/3/25.
//

import Foundation

class MockURLProtocol: URLProtocol {
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
