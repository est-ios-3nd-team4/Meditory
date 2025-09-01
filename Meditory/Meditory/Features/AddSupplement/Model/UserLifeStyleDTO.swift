//
//  UserLifeStyleDTO.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import Foundation

/// 사용자의 생활 패턴(수면 및 식사 시간)을 표현하는 DTO.
///
/// 이 타입은 **네트워크 전송**이나 **ViewModel 데이터 가공** 등
/// 도메인 모델(`UserLifeStyle`)과 분리된 순수 데이터 전달 목적으로 사용됩니다.
struct UserLifeStyleDTO {
  let wakeTime: String
  let sleepTime: String
  let breakfast: String?
  let lunch: String?
  let dinner: String?
}


extension UserLifeStyleDTO {
  static var standard: UserLifeStyleDTO {
    UserLifeStyleDTO(
      wakeTime: "07:00",
      sleepTime: "23:30",
      breakfast: "08:30",
      lunch: "12:00",
      dinner: "19:00"
    )
  }
}


extension UserLifeStyleDTO: Equatable {
  static func == (lhs: UserLifeStyleDTO, rhs: UserLifeStyleDTO) -> Bool {
    return lhs.wakeTime == rhs.wakeTime &&
    lhs.sleepTime == rhs.sleepTime &&
    lhs.breakfast == rhs.breakfast &&
    lhs.lunch == rhs.lunch &&
    lhs.dinner == rhs.dinner
  }
}
