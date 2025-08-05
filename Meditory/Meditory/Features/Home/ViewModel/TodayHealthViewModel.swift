//
//  TodayHealthViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation

final class TodayHealthViewModel: ObservableObject {
    @Published var healthContent: String = "오늘의 건강 정보를 가져오고 있어요."
    private let client: AlanAPIClient
    private let prompt: String
    
    init(client: AlanAPIClient = AlanAPIClient()) {
        self.client = client
        self.prompt =
            """
            <Instruction>
            당신은 한의학과 서양 의학 지식을 겸비한 건강 전문가입니다. 사용자가 일상에서 바로 적용할 수 있는 실용적인 팁을 중심으로, 건강 관련 근거와 효과를 간결하게 설명해주세요. 
            
            <Requirements>
            - 공백 포함 80자 내외
            - 핵심 키워드 2~3개 포함
            - 명확한 행동 제안 포함
            
            <Example>
            아침 식사 전 따뜻한 레몬물 한 잔은 소화 기능을 돕고 면역력 강화에 효과적입니다.
            
            <Query>
            \(sampleExtraInfo)
            
            “오늘의 건강 상식” 키워드에 들어갈 짧고 유익한 문구를 작성해주세요.
            """
    }

    func fetchHealthContent() {
        Task {
            do {
                let result = try await client.request(content: prompt)
                await MainActor.run {
                    self.healthContent = result
                }
            } catch {
                await MainActor.run {
                    healthContent = "아침 식사 전 따뜻한 레몬물 한 잔은 소화 기능을 돕고 면역력 강화에 효과적입니다."
                }
                print("TodayHealthView error:", error)
            }
        }
    }
}
