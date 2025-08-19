//
//  SupplementRoutineAIViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/14/25.
//

import Foundation
import SwiftData

@MainActor
final class SupplementRoutineAIViewModel: ObservableObject {
  private let client: AlanAPIClient
  private let context: ModelContext
  private let userStore: UserStore
  private let routineStore: RoutineStore

  init(
    client: AlanAPIClient = AlanAPIClient(),
    context: ModelContext,
    userStore: UserStore = UserStore(),
    routineStore: RoutineStore = RoutineStore()
  ) {
    self.client = client
    self.context = context
    self.userStore = userStore
    self.routineStore = routineStore

    userStore.loadUser(context: context)
  }

  func requestAISchedule(supplementName: String, lifeStyle: UserLifeStyle) async throws -> SupplementDTO {
    let prompt = makePrompt(supplementName: supplementName, lifestyle: lifeStyle)
    
    print("✅ 요청", Date.now)
    
    let result = try await client.request(content: prompt)
    let dto = try SupplementDecoder.decode(result)
    
    print("✅ 응답", Date.now)
    
    return dto
  }
  
  func makePrompt(supplementName: String, lifestyle: UserLifeStyle) -> String {
    let user = userStore.currentUser
    let gender = user?.gender ?? "미입력"
    let birth = user?.birthDate ?? Date(timeIntervalSince1970: 0)
    let (diseases, allergies, preg, breast) = loadExtraHealthInfo()
    
    let routines = routineStore.fetchAllRoutines(context: context)
    let scheduleList: [String] = (routines.isEmpty ? [] : routines).map { routine in
      let times = routine.routineTimes.map { $0.time.toHHmmString() }.joined(separator: ",")
      let cycleHint = RoutineFormatter.renderCycle(cycleType: routine.cycleType, cycleValue: routine.cycleValue)

      return "\(routine.displayName) (\(times)/\(cycleHint))"
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

  private func loadExtraHealthInfo()
    -> (diseases: [String], allergies: [String], isPregnant: Bool, isBreastfeeding: Bool)
  {
    var diseases: Set<String> = []
    var allergies: Set<String> = []
    var isPregnant = false
    var isBreastfeeding = false

    let all = userStore.fetchExtraInfos(context: context)
    let currentID = userStore.currentUser?.persistentModelID
    let mine = all.filter { $0.user?.persistentModelID == currentID }
    
    for info in mine {
      info.disease.forEach { diseases.formUnion(parseList($0.value)) }
      info.allergy.forEach { allergies.formUnion(parseList($0.value)) }
    }
    
    let _ = userStore.fetchStatuses(context: context).forEach {
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
