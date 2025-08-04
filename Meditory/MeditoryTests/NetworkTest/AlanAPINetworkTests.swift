//
//  AlanAPINetworkTests.swift
//  Meditory
//
//  Created by 홍승아 on 8/3/25.
//

import XCTest
@testable import Meditory

final class AlanAPINetworkTests: XCTestCase {
  
  var session: URLSession!
  var client: AlanAPIClient!
  
  override func setUp() {
    super.setUp()
    
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    
    session = URLSession(configuration: config)
    client = AlanAPIClient(session: session)
  }
  
  // 각 테스트 후에 실행 (메모리 정리 및 핸들러 초기화)
  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    client = nil
    session = nil
    super.tearDown()
  }
  
  func testQuestionEndpoint_ReturnsValidDecodedResponse() async {
    // arrange
    let content = "피로회복에 도움되는 비타민 추천해줘"
    let endpoint = AlanAPIEndpoint.question(content: content)
    guard let request = endpoint.makeURLRequest() else {
      XCTFail("URLReqeust 생성 실패")
      return
    }
    
    // assert
    do {
      let expectedData = "비타민D, 비타민C"
      let expectedJSON = """
      {
        "action": {
          "name": "-",
          "speak": "-"
        },
        "content": "\(expectedData)"
      }
      """
      let url = request.url!
      let response = HTTPURLResponse(
        url: url,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil)!
      
      MockURLProtocol.requestHandler = { request in
        XCTAssertEqual(request.url, url)
        return (expectedJSON.data(using: .utf8), response, nil)
      }
      
      let data = try await client.request(content: content)
      XCTAssertEqual(data, expectedData)
    } catch {
      XCTFail("❌ Error : \(error)")
    }
  }
  
  func testQuestionEndpoint_ReturnsDecodingErrorOnInvalidJSON() async {
    // arrange
    let content = "피로회복에 도움되는 비타민 추천해줘"
    let endpoint = AlanAPIEndpoint.question(content: content)
    guard let request = endpoint.makeURLRequest() else {
      XCTFail("URLRequest 생성 실패")
      return
    }
    
    let invalidJSON = "invalid json"
    let url = request.url!
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    
    MockURLProtocol.requestHandler = { _ in
      return (invalidJSON.data(using: .utf8), response, nil)
    }
    
    do {
      _ = try await client.request(content: content)
      XCTFail("디코딩 에러가 발생해야 함")
    } catch {
      
    }
  }
  
}
