//
//  Questions.swift
//  Meditory
//
//  Created by hyunsic on 8/6/25.
//
import SwiftUI

//struct Questions {
//  static let allergy = [
//    "홍삼, 사상자, 산수유",
//    "강황",
//    "달맞이꽃종자유",
//    "프로폴리스",
//    "석류",
//    "소맥 (보리)",
//    "밀 또는 밀 단백질",
//    "특정 단백질",
//    "무화과",
//    " 난황 (계란)",
//    " 대두",
//    " 호박씨",
//    " 국화과 ( 쑥갓, 카모마일, 해바라기 씨 등)",
//    " 유제품 또는 유당불내증",
//    " 호프추출물",
//    " 땅콩",
//    " 옻",
//    " 갑각류 (게, 새우 등)",
//    " 에스트로겐 민감",
//    " 카페인 민감",
//    " 특정 알러지 (예, 원인을 알 수 없는 알러지)",
//  ]
//  static let diseases = [
//    "간 질환",
//    "갑상선 질환",
//    "고칼슘혈증",
//    "고혈압",
//    "골다공증",
//    "담낭 질환",
//    "당뇨 질환",
//    "뼈/관절 질환",
//    "신장 질환",
//    "심장 질환 (심근경색, 스텐트 시술 등)",
//    "알레르기 질환 (비염, 결막염 등)",
//    "위장 질환",
//    "저혈압",
//    "천식",
//    "혈관 질환 (이상지질혈증 등)",
//    "혈액응고관련 질환",
//    "수술 전후",
//    "각종 암",
//    "피부 광과민성",
//  ]
//  static let medication = [
//    "고지혈증약",
//    "고혈압약",
//    "당뇨약",
//    "면역억제제",
//    "부정맥치료제",
//    "비스테로이드성 항염증제",
//    "신경안정제",
//    "위산분비억제제",
//    "중추신경억제제",
//    "항우울증약",
//    "항응고증약",
//    "항혈소판제",
//    "항혈전제",
//    "혈전용해제",
//    "호르몬제",
//    "수면유도제",
//    "신장에 영향을 미치는 약품",
//  ]
//}

struct QuestionModel: Hashable {
  var title: String
  var subtitle: String = ""
  var symptom: String = ""
  var treatment: String = ""
  var image: String = ""
  var toggleImage: ToggleImageName?
  static let concernModel: [QuestionModel] = [
    .init(title: "간 건강", image: "icon_lung"),
    .init(title: "노화 건강", image: "icon_aging"),
    .init(title: "뼈 건강", image: "icon_bone"),
    .init(title: "뇌 건강", image: "icon_brain"),
    .init(title: "눈 건강", image: "icon_eye"),
    .init(title: "면역 건강", image: "icon_immune"),
    .init(title: "피로 건강", image: "icon_tiredness"),
    .init(title: "폐 건강", image: "icon_bone"),
    .init(title: "근육 건강", image: "icon_muscle"),
    .init(title: "수면 건강", image: "icon_sleep"),
    .init(title: "체중 건강", image: "icon_weight"),
    .init(title: "여성 건강", image: "icon_femine"),
  ]
  static let diseaseModel: [QuestionModel] = [
    .init(title: "간 질환", image: "icon_lung"),
    .init(title: "노화 질환", image: "icon_aging"),
    .init(title: "뼈 질환", image: "icon_bone"),
    .init(title: "뇌 질환", image: "icon_brain"),
    .init(title: "눈 질환", image: "icon_eye"),
    .init(title: "면역 질환", image: "icon_immune"),
    .init(title: "피로 질환", image: "icon_tiredness"),
    .init(title: "폐 질환", image: "icon_bone"),
    .init(title: "근육 질환", image: "icon_muscle"),
    .init(title: "수면 질환", image: "icon_sleep"),
    .init(title: "비만 질환", image: "icon_weight"),
    .init(title: "여성 질환", image: "icon_femine"),
  ]
  static let allergyModel: [QuestionModel] = [
    .init(
      title: "견과류·씨앗류",
      subtitle: "땅콩, 호두, 아몬드, 캐슈넛, 피스타치오, 헤이즐넛 등",
      symptom: "입술·혀 부종, 두드러기, 호흡곤란, 아나필락시스",
      treatment: "즉시 섭취 중단, 에피네프린 사용, 응급실 이동",
      toggleImage: .name(base: "nuts_seeds")
    ),
    .init(
      title: "유제품",
      subtitle: "우유, 치즈, 요거트, 버터",
      symptom: "설사, 복통, 구토, 피부 발진",
      treatment: "무유 식단, 대체 식품(두유, 아몬드유) 활용",
      toggleImage: .name(base: "dairy")
    ),
    .init(
      title: "난류",
      subtitle: "달걀 흰자·노른자",
      symptom: "설사, 피부 발진, 호흡곤란",
      treatment: "무계란 식단, 대체 재료 사용",
      toggleImage: .name(base: "eggs")
    ),
    .init(
      title: "해산물",
      subtitle: "생선, 갑각류, 연체류, 조개류 등",
      symptom: "입·목 가려움, 호흡곤란, 혈압 저하",
      treatment: "섭취·조리 환경 회피, 에피네프린 준비",
      toggleImage: .name(base: "seafood")
    ),
    .init(
      title: "육류",
      subtitle: "소고기, 돼지고기, 닭고기, 양고기, 오리고기",
      symptom: "복통, 발진, 호흡곤란",
      treatment: "특정 육류 회피, 교차오염 주의",
      toggleImage: .name(base: "meat")
    ),
    .init(
      title: "곡물",
      subtitle: "밀(글루텐 포함), 보리, 호밀, 귀리, 옥수수, 메밀",
      symptom: "소화불량, 피부 발진, 호흡기 증상",
      treatment: "글루텐 프리 식단, 대체 곡물 사용",
      toggleImage: .name(base: "grains")
    ),
    .init(
      title: "콩류",
      subtitle: "대두, 병아리콩, 렌틸콩, 강낭콩, 완두콩",
      symptom: "피부 발진, 설사, 입 주위 가려움",
      treatment: "식품 성분표 확인, 원인 회피",
      toggleImage: .name(base: "legumes")
    ),
    .init(
      title: "과일",
      subtitle: "키위, 바나나, 복숭아, 사과, 멜론, 체리, 딸기, 망고, 파인애플",
      symptom: "입·목 가려움, 부종, 구강 알레르기 증후군",
      treatment: "껍질 제거·가열 시 완화 가능",
      toggleImage: .name(base: "fruits")
    ),
    .init(
      title: "채소·향신료",
      subtitle: "셀러리, 토마토, 당근, 고추, 파프리카, 마늘, 양파, 계피, 카레가루",
      symptom: "발진, 구강 알레르기 증후군",
      treatment: "조리하여 섭취, 원인 회피",
      toggleImage: .name(base: "vegetables_spices")
    ),
    .init(
      title: "기타",
      subtitle: "젤라틴, 꿀, 버섯, 초콜릿, 인공 색소·첨가물",
      symptom: "두드러기, 복통, 구토",
      treatment: "원인 회피, 항히스타민제 복용",
      toggleImage: .name(base: "")
    ),
  ]
  static let femineModel: [QuestionModel] = [
    .init(title: "임신 중", subtitle: "임신중에 주의해야하거나\n추천하는 영양성분을 확인할 수 있어요",toggleImage: .name(base: "pregnancy")),
    .init(title: "수유 중", subtitle: "수유중에 주의해야하거나\n추천하는 영양성분을 확인할 수 있어요",toggleImage: .name(base: "breastfeeding"))
  ]
}
