//
//  SupplementRoutineAIViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation
import SwiftData

@Observable
final class SupplementRoutineAIViewModel {
  private let client: AlanAPIClient

  // Store들을 직접 소유하지 않고, 필요할 때 .shared 인스턴스를 사용합니다.
  init(client: AlanAPIClient = AlanAPIClient()) {
    self.client = client
  }

  // AI 추천을 요청하는 View로부터 ModelContext를 전달받습니다.
  func requestAISchedule(
    supplementName: String,
    lifeStyle: UserLifeStyle,
    context: ModelContext
  ) async throws -> SupplementDTO {
    // makePrompt를 호출할 때 context를 전달합니다.
    let prompt = await makePrompt(
      supplementName: supplementName,
      lifestyle: lifeStyle,
      context: context
    )
    
    print("✅ 요청", Date.now)
    
    let result = try await client.request(content: prompt)
    let dto = try SupplementDecoder.decode(result)
    
    print("✅ 응답", Date.now)
    
    return dto
  }
  
  // AI 프롬프트를 생성할 때 ModelContext를 사용합니다.
  func makePrompt(
    supplementName: String,
    lifestyle: UserLifeStyle,
    context: ModelContext
  ) async -> String {
    // UserStore.shared를 직접 사용합니다.
    let user = try? await UserStore.shared.currentUser()
    let gender = user?.gender ?? "미입력"
    let birth = user?.birthDate ?? Date(timeIntervalSince1970: 0)
    let (diseases, allergies, preg, breast) = await loadExtraHealthInfo()
    
    // RoutineStore.shared를 사용해 ID를 가져온 후, 전달받은 context로 실제 객체를 변환합니다.
    let routineIDs = await RoutineStore.shared.fetchAllRoutineIDs()
    let routines = routineIDs.compactMap { context.model(for: $0) as? Routine }
    
    let scheduleList: [String] = routines.map { routine in
      let timeDoseSummary = routine.routineTimes.map { "\($0.time.toHHmmString())(\($0.pillsPerDose)정)" }.joined(separator: ", ")
      let cycleHint = RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)

      return """
           \(routine.displayName)
           - 요일: \(cycleHint)
           - 복용시간: \(timeDoseSummary)
       """
    }

    let input = ScheduleAIPrompt.UserInput(
      gender: gender,
      birthDate: birth,
      diseases: diseases,
      allergies: allergies,
      isPregnant: preg,
      isBreastfeeding: breast,
      supplementSchedule: scheduleList,
      lifestyle: ScheduleAIPrompt.LifestyleLoad.from(lifestyle)
    )

    return ScheduleAIPrompt.makePrompt(user: input, productName: supplementName)
  }

  private func loadExtraHealthInfo() async -> (diseases: [String], allergies: [String], isPregnant: Bool, isBreastfeeding: Bool) {
    var diseases: Set<String> = []
    var allergies: Set<String> = []
    var isPregnant = false
    var isBreastfeeding = false

    let all = await UserStore.shared.fetchExtraInfos()
    let currentID = try? await UserStore.shared.currentUser().persistentModelID
    let mine = all.filter { $0.user?.persistentModelID == currentID }
    
    for info in mine {
      info.disease.forEach { diseases.formUnion(parseList($0.value)) }
      info.allergy.forEach { allergies.formUnion(parseList($0.value)) }
    }
    
    _ = await UserStore.shared.fetchStatuses().forEach {
      let status = $0.statusType
      
      if status.contains("임신") || status.contains("pregnan") {
        isPregnant = true
      }
      if status.contains("수유") || status.contains("breast")  {
        isBreastfeeding = true
      }
    }
    
    return (Array(diseases), Array(allergies), isPregnant, isBreastfeeding)
  }
  
  private func parseList(_ s: String) -> [String] {
    s.split(whereSeparator: { ",/|;".contains($0) })
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
  }

  private func parseBool(_ s: String) -> Bool {
    let v = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return v == "1" || v == "true" || v == "예" || v == "y" || v == "yes"
  }
}
