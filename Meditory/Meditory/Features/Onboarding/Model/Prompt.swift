//
//  Prompt.swift
//  Meditory
//
//  Created by hyunsic on 8/7/25.
//
import Foundation

struct Prompt {
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

  func title(name: String) -> String {
    name + title
  }
  
  func info(context: String) -> String? {
    guard let info else { return ""}
    return "\(context)" + info
  }

  static let promptMessage: [Step: Prompt] = [
    .base: Prompt(title: "나만의 맞춤 영양 설정\n1분이면 끝나요"),
    .gender: Prompt(title: "님의\n성별을 알려주세요", subtitle: "성별", info: ""),
    .allergy: Prompt(title: "님이\n갖고있는 식품관련 알레르기를 모두 알려주세요", info: "알레르기에 따라\n피해야하는 영양성분을 확인할 수 있어요"),
    .disease: Prompt(title: "님이\n갖고있는 질환을 모두 알려주세요", info: "해당 되는 질병을 모두 골라주세요"),
    .concern: Prompt(title: "고민되시거나 개선하고\n싶은 건강 고민을 선택해주세요", info:"개의 고민이 선택되었습니다."),
    .privacyAgree: Prompt(title: "건강 정보 수집 및 이용 동의", info: "개인 맞춤형 복용 스케줄 및 영양제 추천을 위해\n아래와 같은 건강 정보를 수집·이용합니다.")
  ]

}
