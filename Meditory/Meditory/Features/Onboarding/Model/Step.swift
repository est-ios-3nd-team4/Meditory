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
  
  static let stepQuestions:[Step:QuestionMessage] = [
    .name: QuestionMessage(title: "고객님의 이름을 알려주세요",placeHolder:"이름"),
    .age: QuestionMessage(title: "님의 나이를 알려주세요", placeHolder: "나이"),
    .height: QuestionMessage(title: "님의 키를 알려주세요",placeHolder: "신장",unit: "CM"),
    .weight: QuestionMessage(title: "님의 몸무게를 알려주세요",placeHolder: "체중",unit: "KG"),
    .gender: QuestionMessage(title: "님의 성별을 알려주세요"),
    .pregnancy: QuestionMessage(title: "님은 현재 임신중이신가요?"),
    .breastfeeding: QuestionMessage(title: "님은 현재 수유중이신가요?"),
    .hasDisease: QuestionMessage(title: "님은 현재 앓고있는 질병이 있으신가요?"),
    .selectDisease: QuestionMessage(title: "님이 앓고계신 질환을 알려주세요"),
    .hasAllergy: QuestionMessage(title: "님은 식품에 알레르기가 있으시나요?"),
    .selectAllergy: QuestionMessage(title: "님이 갖고있는 모든 식품관련 알러지를 선택해주세요",info:"알레르기에 따라 피해야하는 영양성분을 확인할 수 있어요"),
    .takingMedication: QuestionMessage(title: "님은 현재 복용중인 약물이 있으신가요?"),
    .selectMedication: QuestionMessage(title: "님이 복용중이신 약물을 모두 선택해주세요")
  ]
}



