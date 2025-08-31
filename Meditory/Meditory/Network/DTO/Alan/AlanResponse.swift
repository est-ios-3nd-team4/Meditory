//
//  AlanResponse.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

/// Alan API의 정상 응답을 표현하는 모델
///
/// - 서버 응답 JSON 예시:
/// ```json
/// {
///   "action": {
///     "name": "answer",
///     "speak": "비타민C는 면역력 강화에 도움을 줍니다."
///   },
///   "content": "비타민C는 일반적으로 피로 회복, 면역력 강화에 도움이 됩니다."
/// }
/// ```
struct AlanResponse: Decodable {
  struct Action: Decodable {
    let name: String
    let speak: String
  }
  
  let action: Action
  let content: String
}
