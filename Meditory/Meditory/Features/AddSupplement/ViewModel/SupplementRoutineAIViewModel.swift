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
  private let lifestyle: UserLifeStyle
  private let routineStore: RoutineStore
  
  init(
    client: AlanAPIClient = AlanAPIClient(),
    context: ModelContext,
    userStore: UserStore = UserStore(),
    lifestyle: UserLifeStyle,
    routineStore: RoutineStore = RoutineStore()
  ) {
    self.client = client
    self.context = context
    self.userStore = userStore
    self.lifestyle = lifestyle
    self.routineStore = routineStore
    
    userStore.loadUser(context: context)
  }
  
  /// 상세 진입 전에 AI 추천을 적용합니다.
  /// - Parameters:
  ///   - routine: 대상 루틴
  ///   - skipIfExists: 이미 추천 데이터가 있으면 생략
  /// - Returns: 저장 성공 여부
  func apply(for routine: Routine, skipIfExists: Bool = true) async -> Bool {
    if skipIfExists, hasAIData(in: routine) { return true }
    guard let prompt = makePrompt(for: routine) else { return false }
    
    do {
      let result = try await client.request(content: prompt)
      let dto = try SupplementDecoder.decode(result)
      routineStore.applyRecommendation(from: dto, to: routine, start: Date(), context: context)
      return true
    } catch {
      return false
    }
  }
  
  private func hasAIData(in routine: Routine) -> Bool {
    !routine.recommendedRoutineTimes.isEmpty || !routine.usage.isEmpty || !routine.precautions.isEmpty
  }
  
  /// 실패하지 않도록 기본값을 사용해 프롬프트를 생성
  private func makePrompt(for routine: Routine) -> String? {
    let user = userStore.currentUser
    let gender = user?.gender ?? "미입력"
    let birth = user?.birthDate ?? Date(timeIntervalSince1970: 0)
    let (diseases, allergies, preg, breast) = loadExtraHealthInfo()
    
    let today = Date()
    let routines = routineStore.fetchRoutines(for: today, context: context)
    let scheduleList: [String] = (routines.isEmpty ? [routine] : routines).compactMap { r in
      guard let t = firstTime(of: r) else { return nil }
      return "\(r.displayName)(\(t.toHHmmString()))"
    }
    
    let cycleHint: String? = {
      let base = routines.first ?? routine
      let rendered = RoutineFormatter.renderCycle(cycleType: base.cycleType, cycleValue: base.cycleValue)
      return (rendered == "설정 없음") ? nil : rendered
    }()
    
    let input = SupplementInfoPrompt.UserInput(
      gender: gender,
      birthDate: birth,
      diseases: diseases,
      allergies: allergies,
      isPregnant: preg,
      isBreastfeeding: breast,
      supplementSchedule: scheduleList,
      dosageCycleHint: cycleHint,
      lifestyle: SupplementInfoPrompt.LifestyleLoad.from(lifestyle)
    )
    
    return SupplementInfoPrompt.makePrompt(user: input, productName: routine.displayName)
  }
  
  private func firstTime(of routine: Routine) -> Date? {
    routine.routineTimes.first?.time ?? routine.recommendedRoutineTimes.first?.time
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
      info.concern.forEach {
        let k = $0.key.lowercased()
        if k.contains("임신") || k.contains("pregnan") { isPregnant = parseBool($0.value) }
        if k.contains("수유") || k.contains("breast")  { isBreastfeeding = parseBool($0.value) }
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
