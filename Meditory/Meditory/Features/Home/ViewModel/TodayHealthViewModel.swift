//
//  TodayHealthViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation

final class TodayHealthViewModel: ObservableObject {
  @Published var healthContent: String = ""
  @Published var isLoading: Bool = false

  private let client: AlanAPIClient
  private let prompt: String

  init(client: AlanAPIClient = AlanAPIClient()) {
    self.client = client
    self.prompt =
    """
    <Instruction>
    당신은 한의학과 서양 의학 지식을 겸비한 건강 전문가입니다. 사용자가 일상에서 바로 적용할 수 있는 실용적인 팁을 중심으로, 건강 관련 근거와 효과를 간결하게 설명해주세요. 
    
    <Requirements>
    - 공백 포함 300자 내외
    - 핵심 키워드 2~3개 포함
    - 명확한 행동 제안 포함
    - ""은 불포함한 응답
    
    <Example>
    아침에 스트레칭 5분만 해도 혈액순환이 촉진되고 하루 피로가 줄어듭니다. 서양 의학은 근육 유연성 향상, 한의학은 기혈 흐름 개선 효과를 강조합니다. 매일 일어나자마자 가볍게 목·어깨 돌리기부터 시작해 보세요.
    
    <Query>
    
    “오늘의 건강 상식” 키워드에 들어갈 짧고 유익한 문구를 작성해주세요.
    """
  }

  func fetchHealthContent() {
    Task {
      await MainActor.run { self.isLoading = true }
      do {
        let result = try await client.request(content: prompt)
        await MainActor.run {
          self.healthContent = result
          self.isLoading = false
        }
      } catch {
        await MainActor.run {
          self.healthContent = "아침에 스트레칭 5분만 해도 혈액순환이 촉진되고 하루 피로가 줄어듭니다. 서양 의학은 근육 유연성 향상, 한의학은 기혈 흐름 개선 효과를 강조합니다. 매일 일어나자마자 가볍게 목·어깨 돌리기부터 시작해 보세요."
          self.isLoading = false
        }
        print("TodayHealthView error:", error)
      }
    }
  }
}
