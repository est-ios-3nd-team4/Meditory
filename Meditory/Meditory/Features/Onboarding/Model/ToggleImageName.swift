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
  
  static func name(base:String,normalPrefix:String="icon_clear_",selectPrefix:String="icon_") -> Self {
    .init(normal: normalPrefix + base, selected: selectPrefix + base)
  }
}
