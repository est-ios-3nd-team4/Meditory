//
//  ToggleImageName.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import Foundation

///토글형식의 이미지를 선택여부에 따라 반환하기 위한 헬퍼
struct ToggleImageName:Hashable {
  var normal:String
  var selected:String
  
  func selectedImage(isSelect:Bool) -> String {
    isSelect ? selected : normal
  }
  
  static func name(base:String,normal:String="icon_",select:String="_filled") -> Self {
    .init(normal: normal + base, selected: normal + base + select)
  }
}
