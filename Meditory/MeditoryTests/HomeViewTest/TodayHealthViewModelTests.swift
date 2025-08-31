//
//  TodayHealthViewModelTests.swift
//  MeditoryTests
//
//  Created by 윤혜주 on 8/25/25.
//

import XCTest
@testable import Meditory

/// `TodayHealthViewModel`의 네트워크 호출, 캐시, 중복 요청 제거 로직을 검증하는 단위 테스트입니다.
/// - 테스트 대상 핵심 사항:
///   - **in-flight deduplication**: 동시에 여러 번 호출해도 실제 네트워크는 1회만 발생해야 합니다.
///   - **캐시 재사용**: 첫 성공 이후 동일 호출은 캐시를 사용하여 네트워크 요청을 발생시키지 않습니다.
///   - **강제 갱신(force)**: `force = true`로 호출 시 기존 캐시를 무시하고 새 데이터를 받아옵니다.
@MainActor
final class TodayHealthViewModelTests: XCTestCase {

  /// 테스트용 URLSession (MockURLProtocol을 사용하여 네트워크를 가로채기 위함)
  var session: URLSession!
  /// 테스트 대상이 의존하는 API 클라이언트
  var client: AlanAPIClient!
  /// System Under Test: `TodayHealthViewModel`
  var sut: TodayHealthViewModel!

  /// 각 테스트 시작 전 공통 준비 작업을 수행합니다.
  /// - Mock 프로토콜을 주입한 `URLSession` 구성
  /// - `AlanAPIClient`, `TodayHealthViewModel` 초기화
  /// - 정적 캐시/태스크 상태 초기화(`_resetForTests`)
  override func setUp() {
    super.setUp()
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)

    client = AlanAPIClient(session: session)
    sut = TodayHealthViewModel(client: client)

    TodayHealthViewModel._resetForTests()
  }

  /// 각 테스트 종료 후 공통 정리 작업을 수행합니다.
  /// - Mock 핸들러 제거
  /// - SUT 및 의존 객체 해제
  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    sut = nil
    client = nil
    session = nil
    super.tearDown()
  }

  /// in-flight 중복 제거(deduplication)를 검증합니다.
  /// - 시나리오:
  ///   1) 동일 시점에 `fetchHealthContent()`를 2회 호출합니다.
  ///   2) Mock 네트워크 응답은 1회만 발생해야 합니다.
  ///   3) 두 호출 모두 동일 결과를 수신하고, `sut.healthContent`가 기대 텍스트로 설정되어야 합니다.
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

    // 네트워크 요청을 150ms 지연하여 두 호출이 겹치는 상황을 유도
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

    XCTAssertEqual(requestCount, 1, "동시 다발 호출 시 네트워크 요청은 1회만 발생해야 합니다.")
    XCTAssertEqual(sut.healthContent, expectedText, "중복 제거 후 결과 텍스트가 일치해야 합니다.")
  }

  /// 캐시 재사용 동작을 검증합니다.
  /// - 시나리오:
  ///   1) 첫 호출에서 네트워크를 통해 텍스트를 수신합니다(요청 1회).
  ///   2) 두 번째 동일 호출은 네트워크를 호출하지 않고 캐시 값을 사용합니다(요청 0회 증가).
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
    XCTAssertEqual(requestCount, 1, "첫 호출에서만 네트워크 요청이 수행되어야 합니다.")

    // 두 번째 호출에서는 캐시를 사용해야 하므로 네트워크가 호출되면 실패
    MockURLProtocol.requestHandler = { _ in
      XCTFail("캐시 사용 시 네트워크 요청이 없어야 합니다.")
      return (Data(), ok, nil)
    }
    await sut.fetchHealthContent()

    XCTAssertEqual(sut.healthContent, expectedText)
    XCTAssertEqual(requestCount, 1, "캐시 사용으로 요청 수가 증가하지 않아야 합니다.")
  }

  /// `force = true`로 호출 시, 캐시를 무시하고 새 데이터를 가져오는지 검증합니다.
  /// - 시나리오:
  ///   1) 첫 호출로 캐시를 채웁니다(요청 1회).
  ///   2) `force: true`로 두 번째 호출 → 요청 수가 1 증가하고, 콘텐츠가 갱신되어야 합니다.
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
    XCTAssertEqual(requestCount, 1, "첫 호출로 캐시가 채워져야 합니다.")

    // 응답에 쌍따옴표 금지 정책(요구사항) 준수 여부 추가 점검
    XCTAssertFalse(sut.healthContent.contains("\"\""), "응답에 빈 따옴표가 포함되면 안 됩니다.")

    let secondText = "두 번째(갱신) 텍스트"
    let secondJSON = """
    { "action": { "name": "-", "speak": "-" }, "content": "\(secondText)" }
    """
    MockURLProtocol.requestHandler = { _ in
      requestCount += 1
      return (secondJSON.data(using: .utf8), ok, nil)
    }

    await sut.fetchHealthContent(force: true)

    XCTAssertEqual(requestCount, 2, "force=true 호출 시 네트워크 요청이 추가로 1회 발생해야 합니다.")
    XCTAssertEqual(sut.healthContent, secondText, "강제 갱신 후 최신 텍스트로 교체되어야 합니다.")
  }

  /// SUT가 내부적으로 사용하는 프롬프트 문자열을 반환합니다.
  /// - 테스트 재현성을 위해 프로덕션 코드의 프롬프트와 동일한 형식을 유지합니다.
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
