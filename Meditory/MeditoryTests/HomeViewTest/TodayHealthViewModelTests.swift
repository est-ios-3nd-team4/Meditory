//
//  TodayHealthViewModelTests.swift
//  MeditoryTests
//
//  Created by 윤혜주 on 8/25/25.
//

import XCTest
@testable import Meditory

@MainActor
final class TodayHealthViewModelTests: XCTestCase {

  var session: URLSession!
  var client: AlanAPIClient!
  var sut: TodayHealthViewModel!

  override func setUp() {
    super.setUp()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)

    client = AlanAPIClient(session: session)
    sut = TodayHealthViewModel(client: client)

    TodayHealthViewModel._resetForTests()
  }

  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    sut = nil
    client = nil
    session = nil
    super.tearDown()
  }

  /// 첫 호출 후 추가 호출 방지 (in-flight deduplication)
  func test_fetchHealthContent_deduplicatesInFlightRequests() async {
    let expectedText = "수분 섭취는 피로감 완화에 도움됩니다."
    let expectedJSON = """
    { "action": { "name": "-", "speak": "-" }, "content": "\(expectedText)" }
    """

    let endpoint = AlanAPIEndpoint.question(content: sutValuePrompt())
    guard let req = endpoint.makeURLRequest(), let url = req.url else {
      XCTFail("URLRequest 생성 실패"); return
    }
    let ok = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

    var requestCount = 0
    let firstResponseDelivered = XCTestExpectation(description: "첫 응답 지연 후 전달")

    MockURLProtocol.requestHandler = { _ in
      requestCount += 1
      usleep(150_000)
      firstResponseDelivered.fulfill()
      return (expectedJSON.data(using: .utf8), ok, nil)
    }

    async let a: Void = sut.fetchHealthContent()
    async let b: Void = sut.fetchHealthContent()
    await fulfillment(of: [firstResponseDelivered], timeout: 2.0)
    _ = await (a, b)

    XCTAssertEqual(requestCount, 1)
    XCTAssertEqual(sut.healthContent, expectedText)
  }

  ///  캐시 재사용
  func test_fetchHealthContent_usesCacheOnSecondCall() async {
    let expectedText = "걷기 10분만으로도 컨디션이 좋아집니다."
    let expectedJSON = """
    { "action": { "name": "-", "speak": "-" }, "content": "\(expectedText)" }
    """

    let endpoint = AlanAPIEndpoint.question(content: sutValuePrompt())
    guard let req = endpoint.makeURLRequest(), let url = req.url else {
      XCTFail("URLRequest 생성 실패"); return
    }
    let ok = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

    var requestCount = 0
    MockURLProtocol.requestHandler = { _ in
      requestCount += 1
      return (expectedJSON.data(using: .utf8), ok, nil)
    }

    await sut.fetchHealthContent()
    XCTAssertEqual(sut.healthContent, expectedText)
    XCTAssertEqual(requestCount, 1)

    MockURLProtocol.requestHandler = { _ in
      XCTFail("캐시 사용 시 네트워크 요청이 없어야 합니다.")
      return (Data(), ok, nil)
    }
    await sut.fetchHealthContent()

    XCTAssertEqual(sut.healthContent, expectedText)
    XCTAssertEqual(requestCount, 1)
  }

  /// force=true 시 캐시 무시
  func test_fetchHealthContent_forceIgnoresCache() async {
    let firstText = "첫 번째 텍스트"
    let firstJSON = """
    { "action": { "name": "-", "speak": "-" }, "content": "\(firstText)" }
    """

    let endpoint = AlanAPIEndpoint.question(content: sutValuePrompt())
    guard let req = endpoint.makeURLRequest(), let url = req.url else {
      XCTFail("URLRequest 생성 실패"); return
    }
    let ok = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!

    var requestCount = 0
    MockURLProtocol.requestHandler = { _ in
      requestCount += 1
      return (firstJSON.data(using: .utf8), ok, nil)
    }

    await sut.fetchHealthContent()
    XCTAssertEqual(sut.healthContent, firstText)
    XCTAssertEqual(requestCount, 1)

    XCTAssertFalse(sut.healthContent.contains("\"\""), "응답에 빈 따옴표가 포함되면 안 됨")

    let secondText = "두 번째(갱신) 텍스트"
    let secondJSON = """
    { "action": { "name": "-", "speak": "-" }, "content": "\(secondText)" }
    """
    MockURLProtocol.requestHandler = { _ in
      requestCount += 1
      return (secondJSON.data(using: .utf8), ok, nil)
    }

    await sut.fetchHealthContent(force: true)

    XCTAssertEqual(requestCount, 2)
    XCTAssertEqual(sut.healthContent, secondText)
  }

  private func sutValuePrompt() -> String {
    """
    <Instruction>
    당신은 건강 전문가입니다. 사용자가 일상에서 바로 실천할 수 있는 짧고 실용적인 건강 팁을 제공합니다. 
    근거와 효과는 간결하게 설명하며, 행동 제안을 포함합니다. 가독성이 좋게 답변해주세요.
    
    <Requirements>
    - 공백 포함 150자 내외
    - 핵심 키워드 2~3개 포함
    - 명확한 행동 제안 포함
    - ""은 불포함한 응답
    
    <Example>
    아침에 물 한 컵을 마시면 밤새 부족했던 수분이 보충되고 신진대사가 활성화됩니다. 특히 집중력 향상과 변비 예방에 효과적입니다. 매일 기상 직후 물 한 컵을 습관으로 만들어보세요.
    
    <Query>
    
    “오늘의 건강 상식” 키워드에 들어갈 짧고 유익한 문구를 작성해주세요.
    """
  }
}
