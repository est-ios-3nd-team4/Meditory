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
  
  static let question:[Step:QuestionMessage] = [
    .base: QuestionMessage(title: "나만의 맞춤 영양 설정\n1분이면 끝나요"),
    .gender: QuestionMessage(title: "님의\n성별을 알려주세요",subtitle: "성별"),
    .allergy: QuestionMessage(title: "님이 갖고 있는 식품관련\n알레르기를 모두 알려주세요."),
    .disease: QuestionMessage(title: "님이 갖고 있는 질환을\n모두 알려주세요."),
    .concern: QuestionMessage(title: "고민되시거나 개선하고\n싶은 건강 고민을 선택해주세요.",subtitle: "최대 8개 선택")
  ]
}



