//
//  ScheduleAIPrompt.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation

enum ScheduleAIPrompt {

  struct UserInput: Sendable {
    var gender: String
    var birthDate: Date
    var diseases: [String]
    var allergies: [String]
    var isPregnant: Bool
    var isBreastfeeding: Bool
    var supplementSchedule: [String]
    var lifestyle: UserLifeStyleDTO

    init(
      gender: String,
      birthDate: Date,
      diseases: [String],
      allergies: [String],
      isPregnant: Bool,
      isBreastfeeding: Bool,
      supplementSchedule: [String],
      lifestyle: UserLifeStyleDTO
    ) {
      self.gender = gender
      self.birthDate = birthDate
      self.diseases = diseases
      self.allergies = allergies
      self.isPregnant = isPregnant
      self.isBreastfeeding = isBreastfeeding
      self.supplementSchedule = supplementSchedule
      self.lifestyle = lifestyle
    }

    static func from(
      gender: String,
      birthDate: Date,
      diseases: [String],
      allergies: [String],
      isPregnant: Bool,
      isBreastfeeding: Bool,
      supplementSchedule: [String],
      dosageCycleHint: String? = nil,
      lifestyle: UserLifeStyleDTO
    ) -> UserInput {
      UserInput(
        gender: gender,
        birthDate: birthDate,
        diseases: diseases,
        allergies: allergies,
        isPregnant: isPregnant,
        isBreastfeeding: isBreastfeeding,
        supplementSchedule: supplementSchedule,
        lifestyle: lifestyle
      )
    }
  }

  static let baseRules = """
  [작성 규칙]
  1. LifeStyle, 복용 중인 약·영양제, 질환·알레르기 정보 반영  
  2. 최적화 순서: 흡수율↑ → 상호작용↓(2시간 간격) → 생활패턴 반영 → 간격 유지 → 중복 회피  
  3. schedule.times 작성 시 절대 시각(hour, minute)과 상대 시각(relativeTo, offsetMinutes)을 모두 고려  
     - 사용자의 생활패턴(LifeStyle: 기상, 취침, 아침, 점심, 저녁)을 반영해 relativeTo로 표현  
     - 생활패턴과 무관하게 고정된 절대 시각인 경우 relativeTo="추천"으로 표시  
     - absolute 시간(hour, minute)은 항상 포함  
  4. precautions 작성 시 고정 멘트 대신 상황과 질환, 생활패턴에 맞춰 문장을 유연하게 표현  
  5. 모호한 표현(예: "특별한 주의 사항은 없음") 금지  
  """
  /// 출력 스키마
  static let outputSchema = """
    [출력 JSON 형식]
    {
      "schedule": {
        "cycleType": Int, // 1=요일별, 2=주기별
        "times": [
          { 
            "hour": Int, "minute": Int, "pillsPerDose": Int, 
            "relativeTo": String, "offsetMinutes": Int 
            // 절대 시간(hour, minute) + 상대 시간(relativeTo, offsetMinutes)을 모두 제공
            // relativeTo=["기상","취침","아침","점심","저녁","추천"]
            // "none" → 생활패턴과 무관한 절대 시각
            // ex: {"hour": 8, "minute": 30, "pillsPerDose": 2, "relativeTo": "아침", "offsetMinutes": 30}
            // ex: {"hour": 22, "minute": 0, "pillsPerDose": 1, "relativeTo": "none", "offsetMinutes": 0}
          }
        ],
        "weekdays": [Int] | null, // cycleType=1이면 weekdays만 포함
        "intervalDays": Int | null // cycleType=2이면 intervalDays만 포함
      },
      "usage": [String], // 1~3문장, 공손한 명령형
      "precautions": [String] // 최소 3개 이상, 상황별로 자연스럽게 변형된 문장 사용
    }
    """

  static func buildBaseInstruction(productName: String) -> String {
    """
    <Instruction>
    당신은 **의약품 정보 제공 전문가**이자 **복용 스케줄 추천 도우미**입니다.
    아래 **사용자 건강 정보**를 기반으로 \(productName) 복용 안내를 순수 JSON으로 작성하세요.
    """
  }

  static func renderUserInput(_ user: UserInput) -> String {
    func show(_ v: String?) -> String { v ?? "미입력" }

    let gender = user.gender
    let ageBand = user.birthDate.ageBandString()
    let diseases = user.diseases.isEmpty ? "없음" : user.diseases.joined(separator: ", ")
    let allergies = user.allergies.isEmpty ? "없음" : user.allergies.joined(separator: ", ")
    let preg = user.isPregnant ? "예" : "아니오"
    let breast = user.isBreastfeeding ? "예" : "아니오"
    let items = user.supplementSchedule.isEmpty ? "없음" : user.supplementSchedule.joined(separator: ", ")

    let ls = user.lifestyle
    let lifestyleBlock = """
     - 기상 시간: \(show(ls.wakeTime))
     - 취침 시간: \(show(ls.sleepTime))
     - 아침 식사 시간: \(show(ls.breakfast))
     - 점심 식사 시간: \(show(ls.lunch))
     - 저녁 식사 시간: \(show(ls.dinner))
     """

    return """
     <UserInput>
     * 성별: \(gender)
     * 나이: \(ageBand)
     * 질환: \(diseases)
     * 알레르기: \(allergies)
     * 임신: \(preg)
     * 수유: \(breast)
     * 복용 중 항목 및 시간: \(items)
     
     [LifeStyle]
     \(lifestyleBlock)
     </UserInput>
     """
  }

  static func makePrompt(user: UserInput, productName: String) -> String {
    [
      buildBaseInstruction(productName: productName),
      baseRules,
      renderUserInput(user),
      outputSchema,
      "</Instruction>"
    ].joined(separator: "\n\n")
  }
}
