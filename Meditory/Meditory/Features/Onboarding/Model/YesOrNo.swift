//
//  YesOrNo.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

enum YesOrNo: String, CaseIterable {
  case yes
  case no
  
  var title:String {
    switch self {
      case .yes:
        "예"
      case .no:
        "아니요"
    }
  }
  
  var image:String {
    switch self {
      case .yes:
        "o_icon"
      case .no:
        "x_icon"
    }
  }
}
