//
//  Gender.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

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
        "male_icon"
      case .female:
        "female_icon"
    }
  }
}
