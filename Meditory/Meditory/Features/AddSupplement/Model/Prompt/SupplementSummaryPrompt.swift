//
//  SupplementSummaryPrompt.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 영양제/의약품 정보를 추출하고 요약하기 위한 프롬프트 생성 유틸리티.
struct SupplementSummaryPrompt {
  
  /// AI 모델이 따라야 할 기본 규칙 (JSON 출력 형식, 제약사항 등).
  private static let baseRules = """
    1. 출력은 순수 JSON만 반환하며, JSON 마크다운(```json)으로 감싸지 않습니다.
    2. `type`: 제품이 영양제면 1, 약이면 2로 설정합니다. 만약, 어떤 영양제 혹은 약인지 추론할 수 없다면 3을 설정합니다.
         - `type = 3`인 경우:
           - `name`, `description`, `category`는 "알 수 없음"으로 작성합니다.
           - `usage`, `precautions`은 빈 배열로 보냅니다.
    3. `name`: 추출된 텍스트나 입력한 영양제·약 이름을 바탕으로, 해당 제품의 정확한 명칭을 문자열로 작성합니다.
    4. `description`: 일반적이고 보수적인 설명을 작성합니다.  
       - 의학적 진단/처방 문구 금지  
       - 마케팅/광고성 표현 금지  
       - 제품의 일반적인 효능·용도만 간단히 기술
    5. `category`: 제품이 포함하는 가장 주된 성분명을 문자열로 작성합니다.  
       - 예: 레모나 → "비타민C"  
       - 오메가3 캡슐 → "오메가3"  
       - 루테인 제품 → "루테인"
    6. `usage`: 복용법을 문자열 배열로 작성합니다.
           - 일반적인 복용 방법만 기술
           - 하루 복용량, 복용 시점, 복용 방법 등을 간단명료하게 작성
           - 예: ["하루 1회 1정", "식후 복용", "물과 함께 섭취"]
    7. `precautions`: 주의사항을 문자열 배열로 작성합니다.
       - 일반적인 주의사항만 기술
       - 의학적 진단이나 치료 관련 내용 금지
       - 예: ["임신·수유 중 복용 전 전문의 상담", "어린이 손이 닿지 않는 곳에 보관", "알레르기 반응 시 복용 중단"]
    6. 반드시 네개의 키(`type`, `name`, `description`, `category`)를 모두 포함하며, 불필요한 필드나 주석을 넣지 않습니다.
    """
  
  /// JSON 출력 스키마 (예시 형식).
  private static let outputSchema = """
    [출력 JSON 형식]
    {
      "type": "Int",           
      "name": "String",    
      "description": "String", // (예: 혈관 건강 ・ 시력 유지・ 콜레스테롤 수치 개선에 도움)
      "category": "String", // (예: 비타민C, 오메가3, 루테인)
      "usage": [String],
      "precautions": [String]
    }
    """
  
  /// 사용자가 직접 입력한 제품명을 기반으로 한 지시문 생성.
  private static func buildBaseInstruction(productName: String) -> String {
         """
         당신은 의약품 정보 제공 전문가이자 복용 스케줄 추천 도우미입니다.
         아래 제공된 사용자 건강 정보를 기반으로 **\(productName)**에 대한 복용 안내를 작성하세요.
         """
  }
  
  /// OCR로 추출된 텍스트를 기반으로 한 지시문 생성.
  private static func buildBaseInstruction(extractedText: String) -> String {
      """
      당신은 의약품 정보 제공 전문가이자 복용 스케줄 추천 도우미입니다.
      아래 제공된 사용자 건강 정보를 기반으로, 카메라로 추출한 텍스트를 분석하여
      해당 의약품 또는 건강기능식품의 정확한 제품명을 식별하세요.
      제품명이 불명확한 경우 가능한 후보를 제시하세요.
      
      추출된 텍스트:
      \"\(extractedText)\"
      """
  }
  
  /// 최종 AI 프롬프트 생성
  ///
  /// - Parameters:
  ///   - productNameInput: 사용자 입력값 (직접 입력한 이름 or OCR 텍스트)
  ///   - nameSource: 입력값의 출처 (`.manual` or `.cameraOCR`)
  /// - Returns: AI 모델에 전달할 최종 지시문(String)
  static func makePrompt(
    productNameInput: String,
    nameSource: SupplementNameSource
  ) -> String {
    var sections: [String] = []
    
    switch nameSource {
    case .manual:
      sections.append(buildBaseInstruction(productName: productNameInput))
    case .cameraOCR:
      sections.append(buildBaseInstruction(extractedText: productNameInput))
    }
    
    sections.append(baseRules)
    sections.append(outputSchema)
    
    return sections.joined(separator: "\n\n")
  }
}
