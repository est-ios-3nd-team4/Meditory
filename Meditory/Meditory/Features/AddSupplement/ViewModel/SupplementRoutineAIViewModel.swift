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

  init(client: AlanAPIClient = AlanAPIClient()) {
    self.client = client
  }

  func requestAISchedule(
    supplementName: String,
    lifeStyle: UserLifeStyleDTO,
    context: ModelContext
  ) async throws -> SupplementDTO {
    let prompt = try await makePrompt(
      supplementName: supplementName,
      lifestyle: lifeStyle
    )
    
    print("✅ 요청", Date.now)
    
    let result = try await client.request(content: prompt)
    let dto = try SupplementDecoder.decode(result)
    
    print("✅ 응답", Date.now)
    
    return dto
  }
  
  func makePrompt(
    supplementName: String,
    lifestyle: UserLifeStyleDTO,
    userStore: UserStore = UserStore.shared,
    routineStore: RoutineStore = RoutineStore.shared
  ) async throws -> String {
    
    // 1. User 정보를 가져옵니다.
    let user = try await userStore.currentUser()
    
    let gender = user.gender
    let birth = user.birthDate
    
    // 2. 조회한 user 객체에서 건강 정보를 추출합니다.
    let diseases = user.userExtraInfos.first?.disease.map { $0.value } ?? []
    let allergies = user.userExtraInfos.first?.allergy.map { $0.value } ?? []
    let isPregnant = user.userStatuses.contains { $0.statusType == "임신 중" }
    let isBreastfeeding = user.userStatuses.contains { $0.statusType == "수유 중" }
    
    // 3. 전달받은 context에서 직접 Routine 정보를 가져옵니다.
    let routines = await routineStore.fetchAllRoutines()
    
    let scheduleList: [String] = routines.map { routine in
      let timeDoseSummary = routine.routineTimes
        .sorted { $0.time < $1.time } // 시간을 기준으로 정렬
        .map { "\($0.time.toHHmmString())(\($0.pillsPerDose)정)" }
        .joined(separator: ", ")
      let cycleHint = RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)
      
      return """
                  \(routine.displayName)
                  - 요일: \(cycleHint)
                  - 복용시간: \(timeDoseSummary)
              """
    }
    
    // 4. 추출한 정보들로 프롬프트를 생성합니다.
    let input = ScheduleAIPrompt.UserInput(
      gender: gender,
      birthDate: birth,
      diseases: diseases,
      allergies: allergies,
      isPregnant: isPregnant,
      isBreastfeeding: isBreastfeeding,
      supplementSchedule: scheduleList,
      lifestyle: lifestyle
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
