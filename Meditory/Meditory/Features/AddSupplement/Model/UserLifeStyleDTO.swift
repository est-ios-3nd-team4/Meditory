//
//  UserLifeStyleDTO.swift
//  Meditory
//
//  Created by 홍승아 on 8/26/25.
//

import Foundation

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
