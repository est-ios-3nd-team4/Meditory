//
//  SupplementOCRRedactorTests.swift
//  MeditoryTests
//
//  Created by 홍승아 on 8/31/25.
//

import XCTest
@testable import Meditory

/// `PIIRedactor`가 영양제 OCR 텍스트 내의 개인정보(주소, 전화번호, 이메일 등)를 올바르게 제거하는지 검증하는 단위 테스트
/// - 주요 목적: 제품명, 성분, 브랜드 정보는 유지하되 개인정보만 삭제되는지 확인
final class SupplementOCRRedactorTests: XCTestCase {
  
  /// 긴 멀티라인 영양제 텍스트에서 개인정보(주소, 전화번호, 이메일)를 제거하고
  /// 제품 정보(제품명, 성분, 브랜드)는 그대로 남기는지 테스트
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
  
  /// 여러 개의 제품 정보가 포함된 텍스트에서 각 제품명과 성분은 남기고
  /// 개인정보(주소, 전화번호, 이메일)는 제거되는지 테스트
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
  
  /// 한 줄로 연결된 텍스트에서도 개인정보가 올바르게 제거되는지 테스트
  func testRedactPII_withSingleLineText_removesPIICorrectly() throws {
    // arrange
    let input = "타이레놀 500mg 성분: 아세트아미노펜 브랜드: 존슨앤드존슨 제조원: 경기도 용인시 기흥구 흥덕로 123 소비자 상담실: 080-123-4567 이메일: support@jnj.com"
    
    let expected = "타이레놀 500mg 성분: 아세트아미노펜 브랜드: 존슨앤드존슨 제조원:  소비자 상담실:  이메일: "
    
    // act
    let result = PIIRedactor.redactPII(in: input)
    
    // assert
    XCTAssertEqual(result, expected)
  }
  
  /// 여러 제품 정보가 한 줄로 이어져 있는 경우,
  /// 제품명과 성분은 유지하고 개인정보만 제거되는지 테스트
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
