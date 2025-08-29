// ExtraInfo.swift

import Foundation
import SwiftData

enum ExtraInfoType: String, Codable, CaseIterable {
  case disease
  case allergy
  case concern
  case etc
}

@Model
final class ExtraInfo {
  @Attribute(.unique) var key: String
  var value: String
  private var typeRaw: String
  
  var type: ExtraInfoType {
    get { ExtraInfoType(rawValue: typeRaw) ?? .disease }
    set { typeRaw = newValue.rawValue }
  }
  
  init(key: String, value: String, type: ExtraInfoType) {
    self.key = key
    self.value = value
    self.typeRaw = type.rawValue
  }
}
