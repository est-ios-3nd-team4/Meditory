import Foundation

struct ExtraInfoValue: Identifiable, Hashable {
  var id: String
  var value: String
}

struct ExtraInfoKey: Identifiable, Hashable {
  var id: String
  var title: String
  var values: [ExtraInfoValue]
}

// 앱 실행 시 직접 사용할 더미 데이터
let sampleExtraInfo: [ExtraInfoKey] = [
  ExtraInfoKey(
    id: "disease",
    title: "앓고 있는 질환을 모두 선택하세요",
    values: [
      ExtraInfoValue(id: "disease_1", value: "고혈압"),
      ExtraInfoValue(id: "disease_2", value: "당뇨병"),
      ExtraInfoValue(id: "disease_3", value: "심장병"),
      ExtraInfoValue(id: "disease_4", value: "고지혈증"),
      ExtraInfoValue(id: "disease_5", value: "천식"),
      ExtraInfoValue(id: "disease_6", value: "간질환 (예: 간염)"),
      ExtraInfoValue(id: "disease_7", value: "신장 질환"),
      ExtraInfoValue(id: "disease_8", value: "갑상선 질환"),
      ExtraInfoValue(id: "disease_9", value: "위장 질환 (예: 위염, 역류성 식도염)"),
      ExtraInfoValue(id: "disease_10", value: "골다공증"),
      ExtraInfoValue(id: "disease_11", value: "우울증 / 정신 건강 질환"),
      ExtraInfoValue(id: "disease_12", value: "암 병력"),
      ExtraInfoValue(id: "disease_13", value: "알츠하이머 / 치매"),
      ExtraInfoValue(id: "disease_14", value: "면역 질환 (예: 루푸스, 류마티스 관절염)"),
      ExtraInfoValue(id: "disease_15", value: "수면장애"),
      ExtraInfoValue(id: "disease_16", value: "비만 또는 과체중")
    ]
  ),
  ExtraInfoKey(
    id: "allergy",
    title: "알레르기가 있으신가요?",
    values: [
      ExtraInfoValue(id: "allergy_1", value: "땅콩"),
      ExtraInfoValue(id: "allergy_2", value: "달걀"),
      ExtraInfoValue(id: "allergy_3", value: "우유"),
      ExtraInfoValue(id: "allergy_4", value: "밀"),
      ExtraInfoValue(id: "allergy_5", value: "대두"),
      ExtraInfoValue(id: "allergy_6", value: "견과류 (호두, 아몬드 등)"),
      ExtraInfoValue(id: "allergy_7", value: "생선"),
      ExtraInfoValue(id: "allergy_8", value: "갑각류 (새우, 게 등)"),
      ExtraInfoValue(id: "allergy_9", value: "조개류 (굴, 홍합 등)"),
      ExtraInfoValue(id: "allergy_10", value: "라텍스"),
      ExtraInfoValue(id: "allergy_11", value: "약물 (페니실린 등)"),
      ExtraInfoValue(id: "allergy_12", value: "꽃가루"),
      ExtraInfoValue(id: "allergy_13", value: "동물 비듬"),
      ExtraInfoValue(id: "allergy_14", value: "기타 (직접 입력)")
    ]
  )
]
