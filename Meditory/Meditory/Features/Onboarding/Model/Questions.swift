//
//  Questions.swift
//  Meditory
//
//  Created by hyunsic on 8/6/25.
//
import SwiftUI

/// 각 단계의 화면에서 뷰에 바인하여 쓸 보기 옵션들입니다
struct QuestionModel: Hashable {
  var code: String
  var title: String
  var type: ExtraInfoType
  var subtitle: String = ""
  var symptom: String = ""
  var treatment: String = ""
  var image: String = ""
  var toggleImage: ToggleImageName?
  
  /// 건강모델뷰에서 쓰이는 모델
  static let concernModel: [QuestionModel] = [
    .init(code: "concern_1", title: "고혈압", type: .concern),
    .init(code: "concern_2", title: "당뇨병", type: .concern),
    .init(code: "concern_3", title: "고지혈증", type: .concern),
    .init(code: "concern_4", title: "심혈관 질환", type: .concern),
    .init(code: "concern_5", title: "위장 질환", type: .concern),
    .init(code: "concern_6", title: "간 질환", type: .concern),
    .init(code: "concern_7", title: "신장 질환", type: .concern),
    .init(code: "concern_8", title: "호흡기 질환", type: .concern),
    .init(code: "concern_9", title: "골다공증", type: .concern),
    .init(code: "concern_10", title: "관절 질환", type: .concern),
    .init(code: "concern_11", title: "갑상선 질환", type: .concern),
    .init(code: "concern_12", title: "자가면역 질환", type: .concern),
    .init(code: "concern_13", title: "뇌혈관 질환", type: .concern),
    .init(code: "concern_14", title: "수면장애", type: .concern),
    .init(code: "concern_15", title: "대장 질환", type: .concern),
    .init(code: "concern_16", title: "비만", type: .concern),
    .init(code: "concern_17", title: "대사증후군", type: .concern),
  ]
  
  /// 질환뷰에서 쓰이는 모델
  static let diseaseModel: [QuestionModel] = [
    .init(code: "disease_1", title: "간 질환", type: .disease, image: "icon_liver"),
    .init(code: "disease_2", title: "노화 질환", type: .disease, image: "icon_aging"),
    .init(code: "disease_3", title: "뼈 질환", type: .disease, image: "icon_bone"),
    .init(code: "disease_4", title: "뇌 질환", type: .disease, image: "icon_brain"),
    .init(code: "disease_5", title: "눈 질환", type: .disease, image: "icon_eye"),
    .init(code: "disease_6", title: "면역 질환", type: .disease, image: "icon_immune"),
    .init(code: "disease_7", title: "피로 질환", type: .disease, image: "icon_tiredness"),
    .init(code: "disease_8", title: "폐 질환", type: .disease, image: "icon_lung"),
    .init(code: "disease_9", title: "근육 질환", type: .disease, image: "icon_muscle"),
    .init(code: "disease_10", title: "수면 질환", type: .disease, image: "icon_sleep"),
    .init(code: "disease_11", title: "비만 질환", type: .disease, image: "icon_weight"),
    .init(code: "disease_12", title: "여성 질환", type: .disease, image: "icon_feminine"),
  ]
  
  /// 알러지 뷰에서 쓰이는 모델
  static let allergyModel: [QuestionModel] = [
    .init(
      code: "allergy_1",
      title: "견과류·씨앗류",
      type: .allergy,
      subtitle: "땅콩, 호두, 아몬드, 캐슈넛, 피스타치오, 헤이즐넛 등",
      symptom: "입술·혀 부종, 두드러기, 호흡곤란, 아나필락시스",
      treatment: "즉시 섭취 중단, 에피네프린 사용, 응급실 이동",
      image: "icon_nuts_seeds_filled"
    ),
    .init(
      code: "allergy_2",
      title: "유제품",
      type: .allergy,
      subtitle: "우유, 치즈, 요거트, 버터",
      symptom: "설사, 복통, 구토, 피부 발진",
      treatment: "무유 식단, 대체 식품(두유, 아몬드유) 활용",
      image: "icon_dairy_filled"
    ),
    .init(
      code: "allergy_3",
      title: "난류",
      type: .allergy,
      subtitle: "달걀 흰자·노른자",
      symptom: "설사, 피부 발진, 호흡곤란",
      treatment: "무계란 식단, 대체 재료 사용",
      image: "icon_eggs_filled"
    ),
    .init(
      code: "allergy_4",
      title: "해산물",
      type: .allergy,
      subtitle: "생선, 갑각류, 연체류, 조개류 등",
      symptom: "입·목 가려움, 호흡곤란, 혈압 저하",
      treatment: "섭취·조리 환경 회피, 에피네프린 준비",
      image: "icon_seafood_filled"
    ),
    .init(
      code: "allergy_5",
      title: "육류",
      type: .allergy,
      subtitle: "소고기, 돼지고기, 닭고기, 양고기\n오리고기",
      symptom: "복통, 발진, 호흡곤란",
      treatment: "특정 육류 회피, 교차오염 주의",
      image: "icon_meat_filled"
    ),
    .init(
      code: "allergy_6",
      title: "곡물",
      type: .allergy,
      subtitle: "밀(글루텐 포함), 보리, 호밀, 귀리\n옥수수, 메밀",
      symptom: "소화불량, 피부 발진, 호흡기 증상",
      treatment: "글루텐 프리 식단, 대체 곡물 사용",
      image: "icon_grains_filled"
    ),
    .init(
      code: "allergy_7",
      title: "콩류",
      type: .allergy,
      subtitle: "대두, 병아리콩, 렌틸콩, 강낭콩, 완두콩",
      symptom: "피부 발진, 설사, 입 주위 가려움",
      treatment: "식품 성분표 확인, 원인 회피",
      image: "icon_legumes_filled"
    ),
    .init(
      code: "allergy_8",
      title: "과일",
      type: .allergy,
      subtitle: "키위, 바나나, 복숭아, 사과, 멜론\n체리, 딸기, 망고, 파인애플",
      symptom: "입·목 가려움, 부종, 구강 알레르기 증후군",
      treatment: "껍질 제거·가열 시 완화 가능",
      image: "icon_fruits_filled"
    ),
    .init(
      code: "allergy_9",
      title: "채소·향신료",
      type: .allergy,
      subtitle: "셀러리, 토마토, 당근, 고추, 파프리카\n마늘, 양파, 계피, 카레가루",
      symptom: "발진, 구강 알레르기 증후군",
      treatment: "조리하여 섭취, 원인 회피",
      image: "icon_vegetables_spices_filled"
    ),
    .init(
      code: "allergy_10",
      title: "기타",
      type: .allergy,
      subtitle: "젤라틴, 꿀, 버섯, 초콜릿\n인공 색소·첨가물",
      symptom: "두드러기, 복통, 구토",
      treatment: "원인 회피, 항히스타민제 복용",
      image: "icon_etc_allergy_filled"
    ),
  ]
  
  /// 여성 관련 질환의 모델
  static let feminineModel: [QuestionModel] = [
    .init(
      code: "female_extra_1",
      title: "임신 중",
      type: .etc,
      subtitle: "임신중에 주의해야하거나\n추천하는 영양성분을 확인할 수 있어요",
      image: "icon_pregnancy_filled"
    ),
    .init(
      code: "femal_extra_2",
      title: "수유 중",
      type: .etc,
      subtitle: "수유중에 주의해야하거나\n추천하는 영양성분을 확인할 수 있어요",
      image: "icon_breastfeeding_filled"
    ),
  ]
  
  /// 개인정보 동의 모델
  static let agreements: [QuestionModel] = [
    .init(code: "agree1", title: "[필수] 개인정보 수집 및 이용 동의", type: .etc),
    .init(code: "agree2", title: "[필수] 건강(민감) 정보 수집 및 이용동의", type: .etc)
  ]
}
