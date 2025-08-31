//
//  SupplementNameSource.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 영양제 이름 입력의 출처를 나타내는 열거형.
///
/// 이 값은 API 요청 시 프롬프트 작성 방식에 차이를 두는 데 활용됩니다.
enum SupplementNameSource {
  /// 사용자가 직접 입력한 경우
  case manual
  /// 카메라 OCR(문자 인식)으로 추출된 경우
  case cameraOCR
}
