//
//  SupplementSummary.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import Foundation

/// 영양제 요약 정보를 나타내는 모델
struct SupplementSummary: Codable {
  let type: Int
  let name: String
  let description: String
  let category: String
  var usage: [String] = []
  var precautions: [String] = []
  
  /// 제품을 식별할 수 없는 경우인지 여부
  ///
  /// `type == 3`이면 서버/AI가 제품을 특정하지 못한 상태를 의미합니다.
  var isUnidentifiable: Bool {
    self.type == 3
  }
}
