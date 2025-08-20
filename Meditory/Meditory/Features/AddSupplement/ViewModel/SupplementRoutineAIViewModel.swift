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
  private let context: ModelContext // TODO: 나머지 Store 수정하면서 얘도 삭제
  private let userStore: UserStore
  private let routineStore: RoutineStore

  init(
    client: AlanAPIClient = AlanAPIClient(),
    context: ModelContext, // TODO: 나머지 Store 수정하면서 얘도 삭제
    userStore: UserStore, // Store 는 이것처럼 View 에서 넘겨받는다. ViewModel 이 직접 생성하지 않음.
    routineStore: RoutineStore = RoutineStore()
  ) {
    self.client = client
    self.context = context
    self.userStore = userStore
    self.routineStore = routineStore

    Task { // Store의 메서드를 쓸때는 await 필수
      await userStore.loadUser()
    }
  }

  func requestAISchedule(supplementName: String, lifeStyle: UserLifeStyle) async throws -> SupplementDTO {
    let prompt = await makePrompt(supplementName: supplementName, lifestyle: lifeStyle)
    
    print("✅ 요청", Date.now)
    
    let result = try await client.request(content: prompt)
    let dto = try SupplementDecoder.decode(result)
    
    print("✅ 응답", Date.now)
    
    return dto
  }
  
  func makePrompt(supplementName: String, lifestyle: UserLifeStyle) async -> String { // async 추가
    let user = try? await userStore.currentUser()  //  await 사용
    let gender = user?.gender ?? "미입력"
    let birth = user?.birthDate ?? Date(timeIntervalSince1970: 0)
    let (diseases, allergies, preg, breast) = await loadExtraHealthInfo()
    
    let routines = routineStore.fetchAllRoutines(context: context)
    let scheduleList: [String] = (routines.isEmpty ? [] : routines).map { routine in
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

  private func loadExtraHealthInfo() async
    -> (diseases: [String], allergies: [String], isPregnant: Bool, isBreastfeeding: Bool)
  {
    var diseases: Set<String> = []
    var allergies: Set<String> = []
    var isPregnant = false
    var isBreastfeeding = false

    let all = await userStore.fetchExtraInfos()
    let currentID = try? await userStore.currentUser().persistentModelID
    let mine = all.filter { $0.user?.persistentModelID == currentID }
    
    for info in mine {
      info.disease.forEach { diseases.formUnion(parseList($0.value)) }
      info.allergy.forEach { allergies.formUnion(parseList($0.value)) }
    }
    
    let _ = await userStore.fetchStatuses().forEach {
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
