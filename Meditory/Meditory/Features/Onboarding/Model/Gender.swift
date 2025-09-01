//
//  Gender.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation


/// 성별을 관리하는 속성으로 이름과 이미지를 보유하고 있습니다
enum Gender: String, CaseIterable {
  case male
  case female
  
  var title:String {
    switch self {
      case .male:
        "남성"
      case .female:
        "여성"
    }
  }
  
  var image:String {
    switch self {
      case .male:
        "icon_male"
      case .female:
        "icon_female"
    }
  }
}
