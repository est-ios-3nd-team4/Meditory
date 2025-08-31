//
//  TodayHealthViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation

/// “오늘의 건강 상식” 섹션의 데이터를 관리하는 ViewModel입니다.
/// - 역할:
///   - Alan API 클라이언트를 통해 매일 표시할 짧고 실용적인 건강 팁을 불러옵니다.
///   - 로딩 상태(`isLoading`)와 가져온 텍스트(`healthContent`)를 `@Published`로 바인딩합니다.
/// - 최적화:
///   - 동일한 세션 내 반복 요청 방지를 위해 캐시(cachedContent)를 유지합니다.
///   - 동시에 여러 요청이 발생할 경우 inFlightTask를 공유하여 중복 네트워크 요청을 줄입니다.
/// - 스레드:
///   - 모든 UI 관련 상태 업데이트는 `@MainActor`에서 수행됩니다.
@MainActor
final class TodayHealthViewModel: ObservableObject {
  /// 표시할 건강 상식 문구
  @Published var healthContent: String = ""
  /// 로딩 상태 표시 여부
  @Published var isLoading: Bool = false
  
  /// Alan API 요청 클라이언트
  private let client: AlanAPIClient
  /// 프롬프트 문자열 (건강 상식 요청 규칙)
  private let prompt: String
  
  /// 이전에 가져온 건강 상식 캐시
  private static var cachedContent: String?
  /// 현재 진행 중인 네트워크 요청 Task (중복 호출 방지)
  private static var inFlightTask: Task<String, Error>?
  
  /// 초기화 메서드
  /// - Parameter client: Alan API 요청 클라이언트 (기본값: `AlanAPIClient()`)
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
  
  /// 건강 상식을 가져옵니다.
  /// - Parameter force: `true`일 경우 캐시를 무시하고 새로 요청합니다.
  /// - 동작 순서:
  ///   1. 캐시된 데이터가 있으면 즉시 사용.
  ///   2. 동일 시점에 이미 요청 중인 Task가 있으면 해당 Task 결과를 공유.
  ///   3. 그렇지 않으면 새 네트워크 요청을 생성.
  /// - 실패 시 기본 문구(`fallbackText`)를 반환합니다.
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
  
  /// 요청 실패 시 보여줄 기본 건강 상식 문구
  private static let fallbackText =
  "아침에 물 한 컵을 마시면 밤새 부족했던 수분이 보충되고 신진대사가 활성화됩니다. 특히 집중력 향상과 변비 예방에 효과적입니다. 매일 기상 직후 물 한 컵을 습관으로 만들어보세요."
}

#if DEBUG
extension TodayHealthViewModel {
  /// 테스트용 내부 상태 리셋 메서드
  static func _resetForTests() { cachedContent = nil; inFlightTask = nil }
}
#endif
