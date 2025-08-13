//
//  ToggleImageName.swift
//  Meditory
//
//  Created by hyunsic on 8/11/25.
//

import Foundation

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
