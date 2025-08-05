//
//  Step.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

enum Step: Int, CaseIterable {
  case name
  case age
  case height
  case weight
  case gender
  case pregnancy
  case hasDisease
  case breastfeeding
  case selectDisease
  case hasAllergy
  case selectAllergy
  case takingMedication
  case selectMedication
  case end

  var index: Int {
    return Self.allCases.firstIndex(of: self)!
  }

  static var totalCount: Int {
    return Self.allCases.count
  }

  func next(gender: String,
            isPregnancy: Bool,
           hasDisease: Bool,
           hasAllergy: Bool,
           takesMedication: Bool) -> Step? {
    switch self {
      case .name: return .age
      case .age: return .height
      case .height: return .weight
      case .weight: return .gender
      case .gender:
        return gender == "여성" ? .pregnancy : .hasDisease
      case .pregnancy:
        return isPregnancy ? .breastfeeding : .hasDisease
      case .breastfeeding: return .hasDisease
        
      case .hasDisease:
        return hasDisease ? .selectDisease : .hasAllergy
      case .selectDisease: return .hasAllergy
        
      case .hasAllergy:
        return hasAllergy ? .selectAllergy : .takingMedication
      case .selectAllergy: return .takingMedication
        
      case .takingMedication:
        return takesMedication ? .selectMedication : .end
      case .selectMedication: return .end
        
      case .end:
        return nil
    }
  }

  func previous() -> Step? {
    let idx = index - 1
    return idx >= 0 ? Self.allCases[idx] : nil
  }
}
