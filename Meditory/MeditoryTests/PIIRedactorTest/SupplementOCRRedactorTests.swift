//
//  SupplementOCRRedactorTests.swift
//  MeditoryTests
//
//  Created by 홍승아 on 8/31/25.
//

import XCTest
@testable import Meditory

final class SupplementOCRRedactorTests: XCTestCase {
  
  func testRedactPII_withLongSupplementText_keepsProductInfo_removesPII() throws {
    // arrange
    let input = """
    타이레놀 500mg
    성분: 아세트아미노펜
    브랜드: 존슨앤드존슨
    제조원: 경기도 용인시 기흥구 흥덕로 123
    소비자 상담실: 080-123-4567
    이메일: support@jnj.com
    """
    
    let expected = """
    타이레놀 500mg
    성분: 아세트아미노펜
    브랜드: 존슨앤드존슨
    제조원: 
    소비자 상담실: 
    이메일: 
    """
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withMultipleSupplements_keepsOnlyRelevantInfo() throws {
    // arrange
    let input = """
    제품명: 비타민C 1000mg
    성분: 아스코르빈산
    제조원: 서울특별시 강남구 영동대로 45
    문의: 02-9876-5432
    
    제품명: 오메가3 골드
    성분: 정제어유, 비타민E
    제조원: 부산광역시 해운대구 좌동순환로 77
    고객센터: health@omega.com
    """
    
    let expected = """
    제품명: 비타민C 1000mg
    성분: 아스코르빈산
    제조원: 
    문의: 
    
    제품명: 오메가3 골드
    성분: 정제어유, 비타민E
    제조원: 
    고객센터: 
    """
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withSingleLineText_removesPIICorrectly() throws {
    // arrange
    let input = "타이레놀 500mg 성분: 아세트아미노펜 브랜드: 존슨앤드존슨 제조원: 경기도 용인시 기흥구 흥덕로 123 소비자 상담실: 080-123-4567 이메일: support@jnj.com"
    
    let expected = "타이레놀 500mg 성분: 아세트아미노펜 브랜드: 존슨앤드존슨 제조원:  소비자 상담실:  이메일: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  func testRedactPII_withMultipleSupplementsSingleLine_removesPIICorrectly() throws {
    // arrange
    let input = "제품명: 비타민C 1000mg 성분: 아스코르빈산 제조원: 서울특별시 강남구 영동대로 45 문의: 02-9876-5432 제품명: 오메가3 골드 성분: 정제어유, 비타민E 제조원: 부산광역시 해운대구 좌동순환로 77 고객센터: health@omega.com"
    
    let expected = "제품명: 비타민C 1000mg 성분: 아스코르빈산 제조원:  문의:  제품명: 오메가3 골드 성분: 정제어유, 비타민E 제조원:  고객센터: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
}
