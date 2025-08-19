//
//  SupplementInfoPrompt.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation

enum SupplementInfoPrompt {

  struct LifestyleLoad: Sendable {
    var wakeTimeWeekday: String?
    var sleepTimeWeekday: String?
    var wakeTimeWeekend: String?
    var sleepTimeWeekend: String?
    var breakfastWeekday: String?
    var lunchWeekday: String?
    var dinnerWeekday: String?
    var breakfastWeekend: String?
    var lunchWeekend: String?
    var dinnerWeekend: String?

    init(
      wakeTimeWeekday: String? = nil,
      sleepTimeWeekday: String? = nil,
      wakeTimeWeekend: String? = nil,
      sleepTimeWeekend: String? = nil,
      breakfastWeekday: String? = nil,
      lunchWeekday: String? = nil,
      dinnerWeekday: String? = nil,
      breakfastWeekend: String? = nil,
      lunchWeekend: String? = nil,
      dinnerWeekend: String? = nil
    ) {
      self.wakeTimeWeekday = wakeTimeWeekday
      self.sleepTimeWeekday = sleepTimeWeekday
      self.wakeTimeWeekend = wakeTimeWeekend
      self.sleepTimeWeekend = sleepTimeWeekend
      self.breakfastWeekday = breakfastWeekday
      self.lunchWeekday = lunchWeekday
      self.dinnerWeekday = dinnerWeekday
      self.breakfastWeekend = breakfastWeekend
      self.lunchWeekend = lunchWeekend
      self.dinnerWeekend = dinnerWeekend
    }

    static func from(_ ls: UserLifeStyle) -> LifestyleLoad {
      .init(
        wakeTimeWeekday: ls.wakeTimeWeekday,
        sleepTimeWeekday: ls.sleepTimeWeekday,
        wakeTimeWeekend: ls.wakeTimeWeekend,
        sleepTimeWeekend: ls.sleepTimeWeekend,
        breakfastWeekday: ls.breakfastWeekday,
        lunchWeekday: ls.lunchWeekday,
        dinnerWeekday: ls.dinnerWeekday,
        breakfastWeekend: ls.breakfastWeekend,
        lunchWeekend: ls.lunchWeekend,
        dinnerWeekend: ls.dinnerWeekend
      )
    }
  }

  struct UserInput: Sendable {
    var gender: String
    var birthDate: Date
    var diseases: [String]
    var allergies: [String]
    var isPregnant: Bool
    var isBreastfeeding: Bool
    var supplementSchedule: [String]
    var dosageCycleHint: String?
    var lifestyle: LifestyleLoad?

    init(
      gender: String,
      birthDate: Date,
      diseases: [String],
      allergies: [String],
      isPregnant: Bool,
      isBreastfeeding: Bool,
      supplementSchedule: [String],
      dosageCycleHint: String? = nil,
      lifestyle: LifestyleLoad? = nil
    ) {
      self.gender = gender
      self.birthDate = birthDate
      self.diseases = diseases
      self.allergies = allergies
      self.isPregnant = isPregnant
      self.isBreastfeeding = isBreastfeeding
      self.supplementSchedule = supplementSchedule
      self.dosageCycleHint = dosageCycleHint
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
      lifestyle: UserLifeStyle? = nil
    ) -> UserInput {
      UserInput(
        gender: gender,
        birthDate: birthDate,
        diseases: diseases,
        allergies: allergies,
        isPregnant: isPregnant,
        isBreastfeeding: isBreastfeeding,
        supplementSchedule: supplementSchedule,
        dosageCycleHint: dosageCycleHint,
        lifestyle: lifestyle.map { LifestyleLoad.from($0) }
      )
    }
  }

  static let baseRules = """
  [작성 규칙]
  1. LifeStyle, 복용 중인 약·영양제, 질환·알레르기 정보 반영  
  2. 최적화 순서: 흡수율↑ → 상호작용↓(2시간 간격) → 생활패턴 반영 → 간격 유지 → 중복 회피  
  3. precautions 작성 시 고정 멘트 대신 상황과 질환, 생활패턴에 맞춰 문장을 유연하게 표현  
     - **위장 관련**: 예) "속쓰림이나 소화불량이 있으면 식사 후 복용하세요.", "위장 부담이 될 수 있으니 공복 복용은 피하세요."  
     - **2시간 간격**: 예) "다른 약물과는 최소 2시간 간격을 두세요.", "비슷한 성분 제품은 2시간 이상 간격을 두고 드세요."  
     - **조건부 주의**: 질환·알레르기·임신/수유 상태 반영, 구체적으로 표현  
  4. 모호한 표현(예: "특별한 주의 사항은 없음") 금지  
  """
  /// 출력 스키마
  static let outputSchema = """
    [출력 JSON 형식]
    {
      "type": Int, // 1=영양제, 2=약
      "pillsPerDose": Int,
      "schedule": {
        "cycleType": Int, // 1=요일별, 2=주기별
        "times": [
          { "hour": Int, "minute": Int }, // 절대 시각
          { "relativeTo": String, "offsetMinutes": Int } // relativeTo=["기상","취침","아침","점심","저녁"]
        ],
        "weekdays": [Int] | null, // cycleType=1이면 "weekdays": ["Int"]를 포함하고 "intervalDays"는 쓰지 않음, 월=0~일=6
        "intervalDays": Int | null  // cycleType=2이면 "intervalDays": "Int"를 포함하고 "weekdays"는 쓰지 않음, 며칠 간격
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
    let cycle = user.dosageCycleHint ?? "미입력"


    // user의 lifestyle이 입력되어 있지 않다면 한국 직장인 평균(GPT 피셜) 기준으로 넣음
    let defaultLifestyle = LifestyleLoad(
      wakeTimeWeekday: "07:00",
      sleepTimeWeekday: "23:30",
      wakeTimeWeekend: "08:30",
      sleepTimeWeekend: "00:30",
      breakfastWeekday: "07:30",
      lunchWeekday: "12:30",
      dinnerWeekday: "19:00",
      breakfastWeekend: "09:00",
      lunchWeekend: "13:00",
      dinnerWeekend: "19:00"
    )

    let ls = user.lifestyle ?? defaultLifestyle
    let lifestyleBlock = """
     - 평일 기상: \(show(ls.wakeTimeWeekday))
     - 평일 취침: \(show(ls.sleepTimeWeekday))
     - 평일 아침: \(show(ls.breakfastWeekday))
     - 평일 점심: \(show(ls.lunchWeekday))
     - 평일 저녁: \(show(ls.dinnerWeekday))
     - 주말 기상: \(show(ls.wakeTimeWeekend))
     - 주말 취침: \(show(ls.sleepTimeWeekend))
     - 주말 아침: \(show(ls.breakfastWeekend))
     - 주말 점심: \(show(ls.lunchWeekend))
     - 주말 저녁: \(show(ls.dinnerWeekend))
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
     * 복용 주기: \(cycle)
     
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
