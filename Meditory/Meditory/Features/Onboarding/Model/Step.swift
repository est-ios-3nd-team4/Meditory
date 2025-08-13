//
//  Step.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

enum Step: Int, CaseIterable {
  case base
  case gender
  case allergy
  case disease
  case concern
  
  
  static var totalCount: Int {
    return Self.allCases.count
  }

  func nextView() -> Step? {
    switch self {
      case .base: return .gender
      case .gender: return .allergy
      case .allergy: return .disease
      case .disease: return .concern
      case .concern: return nil
    }
  }
  
  static let prompt:[Step:PromptMessage] = [
    .base: PromptMessage(title: "나만의 맞춤 영양 설정\n1분이면 끝나요"),
    .gender: PromptMessage(title: "님의\n성별을 알려주세요",subtitle: "성별",info:"아래에 해당하는 상태가 있다면 선택해주세요."),
    .allergy: PromptMessage(title: "님이 갖고 있는 식품관련\n알레르기를 모두 알려주세요.",info:"알레르기에 따라 피해야하는 영양성분을 확인할 수 있어요"),
    .disease: PromptMessage(title: "님이 갖고 있는 질환을\n모두 알려주세요.",info:"해당 되는 질병을 모두 골라주세요"),
    .concern: PromptMessage(title: "고민되시거나 개선하고\n싶은 건강 고민을 선택해주세요.",info: "최대 8개 선택 가능")
  ]
}



