//
//  PrivacyRedactorTests.swift
//  MeditoryTests
//
//  Created by 홍승아 on 8/31/25.
//

import XCTest
@testable import Meditory

final class PrivacyRedactorTests: XCTestCase {

  func testRedactPII_withEmail_removesEmail() throws {
    // arrange
    let input = "문의: user@example.com"
    let expected = "문의: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withPhoneNumber_removesPhone() throws {
    // arrange
    let input = "소비자 상담실: 010-1234-5678, 010.1234.5678"
    let expected = "소비자 상담실: , "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withResidentRegistrationNumber_removesRRN() throws {
    // arrange
    let input = "주민등록번호: 900101-1234567"
    let expected = "주민등록번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withCreditCardNumber_removesCard() throws {
    // arrange
    let input = "카드번호: 1234-5678-9012-3456"
    let expected = "카드번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withPassportNumber_removesPassport() throws {
    // arrange
    let input = "여권번호: M12345678"
    let expected = "여권번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withDriverLicenseNumber_removesLicense() throws {
    // arrange
    let input = "운전면허번호: 12-34-567890"
    let expected = "운전면허번호: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
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
