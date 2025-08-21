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
final class ExtraInfo: Sendable {
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

// ----------- 여기부터 스크립트 -------------
//
//let dataDisease: [ExtraInfo] = [
//  ExtraInfo(key: "disease_1", value: "고혈압", type: .disease),
//  ExtraInfo(key: "disease_2", value: "당뇨병", type: .disease),
//  ExtraInfo(key: "disease_3", value: "심장병", type: .disease),
//  ExtraInfo(key: "disease_4", value: "고지혈증", type: .disease),
//  ExtraInfo(key: "disease_5", value: "천식", type: .disease),
//  ExtraInfo(key: "disease_6", value: "간질환 (예: 간염)", type: .disease),
//  ExtraInfo(key: "disease_7", value: "신장 질환", type: .disease),
//  ExtraInfo(key: "disease_8", value: "갑상선 질환", type: .disease),
//  ExtraInfo(key: "disease_9", value: "위장 질환 (예: 위염, 역류성 식도염)", type: .disease),
//  ExtraInfo(key: "disease_10", value: "골다공증", type: .disease),
//  ExtraInfo(key: "disease_11", value: "우울증 / 정신 건강 질환", type: .disease),
//  ExtraInfo(key: "disease_12", value: "암 병력", type: .disease),
//  ExtraInfo(key: "disease_13", value: "알츠하이머 / 치매", type: .disease),
//  ExtraInfo(key: "disease_14", value: "면역 질환 (예: 루푸스, 류마티스 관절염)", type: .disease),
//  ExtraInfo(key: "disease_15", value: "수면장애", type: .disease),
//  ExtraInfo(key: "disease_16", value: "비만 또는 과체중", type: .disease)
//]
//
//let dataAllergy: [ExtraInfo] = [
//  ExtraInfo(key: "allergy_1", value: "땅콩", type: .allergy),
//  ExtraInfo(key: "allergy_2", value: "달걀", type: .allergy),
//  ExtraInfo(key: "allergy_3", value: "우유", type: .allergy),
//  ExtraInfo(key: "allergy_4", value: "밀", type: .allergy),
//  ExtraInfo(key: "allergy_5", value: "대두", type: .allergy),
//  ExtraInfo(key: "allergy_6", value: "견과류 (호두, 아몬드 등)", type: .allergy),
//  ExtraInfo(key: "allergy_7", value: "생선", type: .allergy),
//  ExtraInfo(key: "allergy_8", value: "갑각류 (새우, 게 등)", type: .allergy),
//  ExtraInfo(key: "allergy_9", value: "조개류 (굴, 홍합 등)", type: .allergy),
//  ExtraInfo(key: "allergy_10", value: "라텍스", type: .allergy),
//  ExtraInfo(key: "allergy_11", value: "약물 (페니실린 등)", type: .allergy),
//  ExtraInfo(key: "allergy_12", value: "꽃가루", type: .allergy),
//  ExtraInfo(key: "allergy_13", value: "동물 비듬", type: .allergy),
//  ExtraInfo(key: "allergy_14", value: "기타 (직접 입력)", type: .allergy)
//]
//
//let dataConcern: [ExtraInfo] = [
//  ExtraInfo(key: "concern_1", value: "피부 건강", type: .concern),
//  ExtraInfo(key: "concern_2", value: "피로감", type: .concern),
//  ExtraInfo(key: "concern_3", value: "장 건강", type: .concern),
//  ExtraInfo(key: "concern_4", value: "눈 건강", type: .concern),
//  ExtraInfo(key: "concern_5", value: "체지방", type: .concern),
//  ExtraInfo(key: "concern_6", value: "스트레스 & 수면", type: .concern)
//]
//
//// 전체 데이터 합본
//let allInitialExtraInfos = dataDisease + dataAllergy + dataConcern
