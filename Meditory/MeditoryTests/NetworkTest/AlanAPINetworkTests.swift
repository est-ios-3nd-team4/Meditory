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
  
  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    client = nil
    session = nil
    super.tearDown()
  }
  
  /// `AlanAPIEndpoint.question` 요청 시,
  /// 서버가 올바른 JSON을 반환하면 정상적으로 디코딩되어 응답 문자열을 받는지 확인합니다.
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
  
  /// 서버가 잘못된 JSON 응답을 반환할 경우,
  /// `AlanAPIClient`가 디코딩 에러를 발생시키는지 확인합니다.
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
