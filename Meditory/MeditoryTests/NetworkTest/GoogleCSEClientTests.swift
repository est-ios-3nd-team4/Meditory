import XCTest
@testable import Meditory

final class GoogleCSEClientTests: XCTestCase {

  var session: URLSession!
  var client: GoogleCSEImageClient!

  override func setUp() {
    super.setUp()

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)

    // 세션 주입 + 파서 스텁 주입
    client = GoogleCSEImageClient(apiKey: "dummy-key",
                                  cx: "dummy-cx",
                                  titleParser: StubTitleParser(),
                                  session: session)
  }

  override func tearDown() {
    MockURLProtocol.requestHandler = nil
    client = nil
    session = nil
    super.tearDown()
  }

  // MARK: - fetchImageAndLink

  func test_fetchImageAndLink_success_parsesAndCaches() async throws {
    // given
    let brand = "스포츠리서치"
    let name  = "트리플 스트렝스 오메가3 피쉬오일"

    let json = """
    {
      "items": [
        {
          "link": "https://img.example.com/a.jpg",
          "image": {
            "contextLink": "https://shop.example.com/p/1",
            "thumbnailLink": "https://img.example.com/a_thumb.jpg"
          }
        }
      ]
    }
    """

    var hitCount = 0
    MockURLProtocol.requestHandler = { req in
      hitCount += 1
      let resp = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (json.data(using: .utf8), resp, nil)
    }

    // when
    let r1 = try await client.fetchImageAndLink(for: brand, name: name)
    let r2 = try await client.fetchImageAndLink(for: brand, name: name) // 같은 쿼리 -> 캐시 적중

    // then
    XCTAssertEqual(hitCount, 1, "같은 쿼리는 캐시 사용으로 한 번만 네트워크 호출되어야 함")
    XCTAssertEqual(r1?.imageURL, "https://img.example.com/a.jpg")
    XCTAssertEqual(r1?.productLink, "https://shop.example.com/p/1")
    XCTAssertEqual(r2?.imageURL, "https://img.example.com/a.jpg")
  }

  func test_fetchImageAndLink_non200_throwsHTTPError() async {
    // given
    MockURLProtocol.requestHandler = { req in
      let resp = HTTPURLResponse(url: req.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
      return ("SERVER ERR".data(using: .utf8), resp, nil)
    }

    // when
    do {
      _ = try await client.fetchImageAndLink(for: "A", name: "B")
      XCTFail("여기 오면 안 됨")
    } catch {
      // then
      // CSEError.http(status:body:) 형태일 것. 타입이 다르면 일반 오류로만 체크
      if case let CSEError.http(status, _) = error {
        XCTAssertEqual(status, 500)
      } else {
        XCTFail("CSEError.http 가 나와야 함, got: \(error)")
      }
    }
  }

  func test_fetchImageAndLink_decodeError_throwsDecode() async {
    // given
    MockURLProtocol.requestHandler = { req in
      let resp = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return ("{ invalid json".data(using: .utf8), resp, nil)
    }

    // when
    do {
      _ = try await client.fetchImageAndLink(for: "A", name: "B")
      XCTFail("여기 오면 안 됨")
    } catch {
      if case CSEError.decode = error {
        // ok
      } else {
        XCTFail("CSEError.decode 가 나와야 함, got: \(error)")
      }
    }
  }

  func test_fetchImageAndLink_noItems_returnsNil() async throws {
    // given
    let json = #"{"items": []}"#
    MockURLProtocol.requestHandler = { req in
      let resp = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (json.data(using: .utf8), resp, nil)
    }

    // when
    let result = try await client.fetchImageAndLink(for: "X", name: "Y")

    // then
    XCTAssertNil(result, "아이템이 없으면 nil 리턴")
  }

  func test_fetchImageAndLink_emptyAPIKeyOrCX_returnsNil_noRequest() async throws {
    // given: 키/식별자 없음 -> 조기 반환
    let emptyClient = GoogleCSEImageClient(apiKey: "", cx: "", titleParser: StubTitleParser(), session: session)

    // 요청이 오면 실패하도록 핸들러 설정
    MockURLProtocol.requestHandler = { _ in
      XCTFail("API 키/식별자 없으면 네트워크를 타면 안 됨")
      let resp = HTTPURLResponse(url: URL(string:"https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (Data(), resp, nil)
    }

    // when
    let result = try await emptyClient.fetchImageAndLink(for: "brand", name: "name")

    // then
    XCTAssertNil(result)
  }

  // MARK: - fetchPillyzePage

  func test_fetchPillyzePage_success_parsesTwoProducts() async throws {
    // given
    let json = """
    {
      "items": [
        {
          "link": "https://pillyze.com/products/111",
          "title": "[브랜드A] 제품A - 필라이즈",
          "displayLink": "pillyze.com",
          "pagemap": {
            "product": [{
              "name": "제품A 정식명",
              "brand": { "name": "브랜드A" }
            }],
            "cse_image": [{ "src": "https://img.cdn.com/a.jpg" }],
            "metatags": [{ "product:brand": "브랜드A" }]
          }
        },
        {
          "link": "https://pillyze.com/products/222",
          "title": "무브랜드 타이틀 예시 | 필라이즈",
          "displayLink": "pillyze.com",
          "pagemap": {
            "cse_thumbnail": [{ "src": "https://img.cdn.com/b_thumb.jpg" }],
            "imageobject": [{ "url": "https://img.cdn.com/b.jpg" }],
            "metatags": [{ "product:brand": "" }]
          }
        },
        {
          "link": "https://other.com/abc",
          "title": "다른 사이트",
          "pagemap": {}
        }
      ]
    }
    """

    MockURLProtocol.requestHandler = { req in
      XCTAssertTrue(req.url?.absoluteString.contains("siteSearch=pillyze.com") == true)
      let resp = HTTPURLResponse(url: req.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (json.data(using: .utf8), resp, nil)
    }

    let results = try await client.fetchPillyzePage(query: "오메가3", start: 1, num: 5)

    XCTAssertEqual(results.count, 2, "/products 링크만 남아야 함")
    XCTAssertEqual(results[0].brand, "브랜드A")
    XCTAssertEqual(results[0].name, "제품A 정식명")
    XCTAssertEqual(results[0].imageURL, "https://img.cdn.com/a.jpg")
    XCTAssertEqual(results[0].link, "https://pillyze.com/products/111")
    XCTAssertEqual(results[1].brand, "TITLE_BRAND")
    XCTAssertEqual(results[1].name, "TITLE_NAME")
    XCTAssertEqual(results[1].imageURL, "https://img.cdn.com/b_thumb.jpg")
  }

  func test_fetchPillyzePage_non200_throwsHTTPError() async {
    MockURLProtocol.requestHandler = { req in
      let resp = HTTPURLResponse(url: req.url!, statusCode: 429, httpVersion: nil, headerFields: nil)!
      return ("quota exceeded".data(using: .utf8), resp, nil)
    }
    do {
      _ = try await client.fetchPillyzePage(query: "유산균", start: 1)
      XCTFail("여기 오면 안 됨")
    } catch {
      if case let CSEError.http(status, _) = error {
        XCTAssertEqual(status, 429)
      } else {
        XCTFail("CSEError.http 가 나와야 함, got: \(error)")
      }
    }
  }
}
