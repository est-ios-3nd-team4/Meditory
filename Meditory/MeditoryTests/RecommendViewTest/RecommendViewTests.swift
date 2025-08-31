import XCTest
@testable import Meditory

final class ProductCodableTests: XCTestCase {

  // 1) 최소 JSON 디코딩 시, 기본값들이 올바르게 채워지는지 확인
  func test_ProductDecoding_defaultsAreFilled() throws {
    // given: brand, name만 포함된 최소 JSON
    let json = """
        {
            "brand": "테스트브랜드",
            "name": "테스트제품"
        }
        """.data(using: .utf8)!

    // when
    let decoded = try JSONDecoder().decode(Product.self, from: json)

    // then
    XCTAssertEqual(decoded.brand, "테스트브랜드")
    XCTAssertEqual(decoded.name, "테스트제품")
    XCTAssertEqual(decoded.imageName, "", "imageName은 CodingKeys에 없으므로 기본값 \"\" 여야 함")
    XCTAssertNil(decoded.link, "link는 CodingKeys에 없으므로 nil이어야 함")
    let second = Product(brand: "B", name: "C")
    XCTAssertNotEqual(decoded.id, second.id, "각 Product의 id는 기본적으로 서로 달라야 함")
  }

  // 2) 인코딩 시 CodingKeys(brand, name)만 포함되고 id/imageName/link는 제외되는지 확인
  func test_ProductEncoding_excludesNonCodingKeys() throws {
    // given
    let product = Product(
      imageName: "https://example.com/img.jpg",
      brand: "브랜드",
      name: "이름",
      link: "https://example.com"
    )

    // when
    let data = try JSONEncoder().encode(product)
    let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]

    // then
    XCTAssertNotNil(obj)
    XCTAssertEqual(obj?["brand"] as? String, "브랜드")
    XCTAssertEqual(obj?["name"] as? String, "이름")

    XCTAssertNil(obj?["id"], "id는 인코딩에 포함되면 안 됨")
    XCTAssertNil(obj?["imageName"], "imageName은 인코딩에 포함되면 안 됨")
    XCTAssertNil(obj?["link"], "link는 인코딩에 포함되면 안 됨")

    // 키 전체 집합도 검증
    let keys = Set(obj!.keys)
    XCTAssertEqual(keys, ["brand", "name"], "인코딩 키는 brand, name 두 개만 존재해야 함")
  }

  // 3) brand/name만 인코딩 → 다시 디코딩했을 때, brand/name은 보존되고 나머지는 기본값으로 복구되는지 확인
  func test_ProductRoundTrip_brandNameArePreservedOthersDefault() throws {
    // given
    let original = Product(
      imageName: "should-not-encode",
      brand: "보존브랜드",
      name: "보존이름",
      link: "https://should-not-encode.com"
    )

    // when
    let encoded = try JSONEncoder().encode(original)
    let roundTripped = try JSONDecoder().decode(Product.self, from: encoded)

    // then
    XCTAssertEqual(roundTripped.brand, "보존브랜드")
    XCTAssertEqual(roundTripped.name, "보존이름")

    XCTAssertEqual(roundTripped.imageName, "", "imageName은 기본값으로 복원되어야 함")
    XCTAssertNil(roundTripped.link, "link는 기본값(nil)로 복원되어야 함")

    XCTAssertNotEqual(original.id, roundTripped.id, "id는 인코딩/디코딩을 거치며 동일할 필요 없음")
  }

  // 4) 기본 생성 시 UUID가 유니크하게 생성되는지(충분한 표본) 확인
  func test_ProductInit_uniqueIDs() {
    // given
    let count = 200
    let products = (0..<count).map { _ in Product(brand: "B", name: "N") }

    // when
    let uniqueIDs = Set(products.map { $0.id })

    // then
    XCTAssertEqual(uniqueIDs.count, count, "기본 생성된 Product의 id는 유니크해야 함")
  }
}
