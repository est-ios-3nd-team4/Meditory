//
//  QuestionMessage.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

struct QuestionMessage {
  let title: String
  let subtitle: String?
  let placeHolder: String?
  let info: String?
  let unit: String?
  
  init(title: String, subtitle: String? = nil, placeHolder: String? = nil, info: String? = nil, unit: String? = nil) {
    self.title = title
    self.subtitle = subtitle
    self.placeHolder = placeHolder
    self.info = info
    self.unit = unit
  }
  
  func title(name:String)->String {
    name + title
  }
}
