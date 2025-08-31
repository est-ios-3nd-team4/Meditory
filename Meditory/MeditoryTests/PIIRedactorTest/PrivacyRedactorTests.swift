//
//  PrivacyRedactorTests.swift
//  MeditoryTests
//
//  Created by 홍승아 on 8/31/25.
//

import XCTest
@testable import Meditory

/// `PIIRedactor` 유틸리티가 개인정보(PII)를 올바르게 비식별화하는지 검증하는 단위 테스트
final class PrivacyRedactorTests: XCTestCase {

  /// 이메일 주소가 제거되는지 테스트
  func testRedactPII_withEmail_removesEmail() throws {
    // arrange
    let input = "문의: user@example.com"
    let expected = "문의: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 전화번호(하이픈/점 구분 포함)가 제거되는지 테스트
  func testRedactPII_withPhoneNumber_removesPhone() throws {
    // arrange
    let input = "소비자 상담실: 010-1234-5678, 010.1234.5678"
    let expected = "소비자 상담실: , "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 주민등록번호(앞6자리-뒤7자리, 또는 앞6자리-뒤1자리)가 제거되는지 테스트
  func testRedactPII_withResidentRegistrationNumber_removesRRN() throws {
    // arrange
    let input = "주민등록번호: 900101-1234567, 900101-1"
    let expected = "주민등록번호: , "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 신용카드 번호(16자리)가 제거되는지 테스트
  func testRedactPII_withCreditCardNumber_removesCard() throws {
    // arrange
    let input = "카드번호: 1234-5678-9012-3456"
    let expected = "카드번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 여권번호(문자+숫자 조합)가 제거되는지 테스트
  func testRedactPII_withPassportNumber_removesPassport() throws {
    // arrange
    let input = "여권번호: M12345678"
    let expected = "여권번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 운전면허번호(지역코드+일련번호)가 제거되는지 테스트
  func testRedactPII_withDriverLicenseNumber_removesLicense() throws {
    // arrange
    let input = "운전면허번호: 12-34-567890"
    let expected = "운전면허번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 주소 문자열(도/시/구/도로명+번지)이 제거되는지 테스트
  func testRedactPII_withAddress_removesAddress() throws {
    // arrange
    let input = "제조원: 경기도 용인시 기흥구 흥덕로 123"
    let expected = "제조원: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
}
