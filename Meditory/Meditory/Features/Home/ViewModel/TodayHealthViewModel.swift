//
//  TodayHealthViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation

@MainActor
final class TodayHealthViewModel: ObservableObject {
  @Published var healthContent: String = ""
  @Published var isLoading: Bool = false

  private let client: AlanAPIClient
  private let prompt: String

  private static var cachedContent: String?
  private static var inFlightTask: Task<String, Error>?

  init(client: AlanAPIClient = AlanAPIClient()) {
    self.client = client
    self.prompt =
    """
    <Instruction>
    당신은 건강 전문가입니다. 사용자가 일상에서 바로 실천할 수 있는 짧고 실용적인 건강 팁을 제공합니다. 
    근거와 효과는 간결하게 설명하며, 행동 제안을 포함합니다. 가독성이 좋게 답변해주세요.

    <Requirements>
    - 공백 포함 150자 내외
    - 핵심 키워드 2~3개 포함
    - 명확한 행동 제안 포함
    - ""은 불포함한 응답
    - 오늘의 건강 상식은 출력하지 않습니다
    - 문장 내에 특수 문자는 생략해주세요
    - 마크다운과 관련된 언어도 생략합니다. 특히 마크다운의 *이나 **은 추가하지 않습니다

    <Example>
    아침에 물 한 컵을 마시면 밤새 부족했던 수분이 보충되고 신진대사가 활성화됩니다. 특히 집중력 향상과 변비 예방에 효과적입니다. 매일 기상 직후 물 한 컵을 습관으로 만들어보세요.

    <Query>
    “오늘의 건강 상식” 키워드에 들어갈 짧고 유익한 문구를 작성해주세요.
    """
  }

  func fetchHealthContent(force: Bool = false) async {
    if let cached = Self.cachedContent, !force {
      self.healthContent = cached
      self.isLoading = false
      return
    }

    if let task = Self.inFlightTask, !force {
      isLoading = true
      do {
        let text = try await task.value
        self.healthContent = text
      } catch {
        self.healthContent = Self.fallbackText
        print("TodayHealthView error:", error)
      }
      self.isLoading = false
      return
    }

    isLoading = true
    let task = Task<String, Error> { [client, prompt] in
      try await client.request(content: prompt)
    }
    Self.inFlightTask = task

    do {
      let text = try await task.value
      Self.cachedContent = text
      self.healthContent = text
    } catch {
      self.healthContent = Self.fallbackText
      print("TodayHealthView error:", error)
    }

    Self.inFlightTask = nil
    isLoading = false
  }

  private static let fallbackText = "아침에 물 한 컵을 마시면 밤새 부족했던 수분이 보충되고 신진대사가 활성화됩니다. 특히 집중력 향상과 변비 예방에 효과적입니다. 매일 기상 직후 물 한 컵을 습관으로 만들어보세요."
}
#if DEBUG
extension TodayHealthViewModel {
  static func _resetForTests() { cachedContent = nil; inFlightTask = nil }
}
#endif
