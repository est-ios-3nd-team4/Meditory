import Foundation
import SwiftData

@MainActor
final class NutrientViewModel: ObservableObject {
  @Published var chip: [String] = []
  @Published var recommend: [Nutrient] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let client = AlanAPIClient()

  private struct AINutrient: Codable, Identifiable {
    let id: String
    let name: String
    var hashtags: [String]
    let title: String
    let content: String
  }

  func saveRecommendations(to context: ModelContext) {
    do {
      let stored = try context.fetch(FetchDescriptor<Nutrient>())
      var byId: [String: Nutrient] = [:]
      for item in stored { byId[item.id] = item }

      for n in recommend {
        if let existing = byId[n.id] {
          existing.name = n.name
          existing.hashtags = n.hashtags
          existing.desc = n.desc
          existing.title = n.title
          existing.content = n.content
          existing.positiveKeywords = n.positiveKeywords
          existing.negativeKeywords = n.negativeKeywords
        } else {
          context.insert(n)
        }
      }
      try context.save()
    } catch {
      print(error)
    }
  }

  private func sanitize(_ items: [AINutrient]) -> [AINutrient] {
    items.prefix(3).map { item in
      var hashtags = item.hashtags
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

      var seen = Set<String>()
      hashtags = hashtags.filter {
        let dedupKey = $0.lowercased().replacingOccurrences(of: " ", with: "")
        return seen.insert(dedupKey).inserted
      }

      if hashtags.count > 2 { hashtags = Array(hashtags.prefix(2)) }
      var updatedItem = item
      updatedItem.hashtags = hashtags
      return updatedItem
    }
  }

  private func toNutrients(_ ai: [AINutrient]) -> [Nutrient] {
    sanitize(ai).map {
      Nutrient(
        id: $0.id,
        name: $0.name,
        hashtags: $0.hashtags,
        description: "",
        title: $0.title,
        content: $0.content,
        positiveKeywords: [],
        negativeKeywords: []
      )
    }
  }

  private func prompt(userName: String?) -> String {
//    let display = userName ?? "@@"
//    return """
//      [역할]
//      - 당신은 한국 사용자에게 식단/생활습관/건강정보를 바탕으로 영양성분을 추천하는 영양 코치입니다.
//      - 의학적 진단이나 처방을 대체하지 않습니다. 위험 신호가 있으면 전문의 상담을 권고합니다.
//      
//      [목표]
//      - 사용자 입력을 분석하여 "중복되지 않는" 영양성분 최대 3가지를 추천합니다.
//      - 각 성분에 대해 간결한 해시태그(최대 2개), 한 문장 헤드라인(title), 3~6문장 설명(content)을 제공합니다.
//      
//      [출력 형식(중요)]
//      - **JSON 배열만** 출력하세요. 다른 텍스트/코드블록/주석 금지.
//      - 각 원소 스키마:
//        - id: string (영문 스네이크/케밥 케이스, 고유)
//        - name: string (한국어 성분명, 예: "아연")
//        - hashtags: string[] (0~2개, 짧은 근거 키워드, 예: "면역 기능", "간 건강")
//        - title: string (한 문장 요약, 확정 표현 금지: "~에 도움을 줄 수 있음" 톤)
//        - content: string (이유/권장량 범위/식품 급원/주의·금기 포함, 3~6문장, 단위 표기)
//      
//      [품질 규칙]
//      - 과대광고·확정적 표현 금지(“~에 도움을 줄 수 있음”).
//      - 금기(알레르기/질환/복용약)와 중복 효능 회피(예: 오메가3 vs 크릴오일 동시 추천 지양).
//      - 식품 급원 1~2개 예시 포함(예: 굴, 붉은살코기 등).
//      - 불확실하거나 위험 신호 시 “전문의 상담 권고” 문구 포함.
//      
//      [금지]
//      - description, positiveKeywords, negativeKeywords 등 **스키마 외 필드 출력 금지**.
//      - 제품/브랜드 추천 금지.
//      
//      [예시]
//      [
//        {
//          "id": "zinc",
//          "name": "아연",
//          "hashtags": ["면역 기능", "세포분열"],
//          "title": "아연은 해산물 섭취가 적을 때 부족해지기 쉬우며 면역에 도움을 줄 수 있습니다.",
//          "content": "아연은 면역 반응과 세포분열에 관여합니다. 한국 성인 권장량은 대략 8~11㎎/일입니다. 굴·붉은살코기·콩류에 풍부합니다. 과다 섭취는 구리 결핍을 유발할 수 있어 상한섭취량(40㎎/일)을 넘지 않도록 하세요."
//        }
//      ]
//      
//      [사용자]
//        - 대상: \(display)
//      
//        [최종 지시]
//        - 오직 유효한 JSON 배열 **문자열만** 반환하세요. 앞뒤 설명/마크다운/코드블록을 절대 추가하지 마세요.
//      """
    let display = (userName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? userName! : "@@"
      let isDemo = (display == "@@")

      let demoBlock = isDemo ? """
      [입력 없음 처리(데모)]
      - 사용자 데이터가 없으므로 아래 디폴트 프로필을 가정해 결과를 생성하세요.
      - 디폴트 프로필:
        • 20~40대 사무직, 좌식 활동이 많음, 햇빛 노출 적음
        • 해산물 섭취 적고, 카페인 섭취는 다소 높음, 불규칙한 식사
        • 최근 피로/집중 저하 호소 가능
      - 반드시 3개 성분을 추천하세요(중복 효능/유사 원료 동시 추천 금지).
      """ : ""

      return """
      [역할]
      - 당신은 한국 사용자에게 식단/생활습관/건강정보를 바탕으로 영양성분을 추천하는 영양 코치입니다.
      - 의학적 진단이나 처방을 대체하지 않습니다. 위험 신호가 있으면 전문의 상담을 권고합니다.

      [목표]
      - 사용자 입력을 분석하여 "중복되지 않는" 영양성분 최대 3가지를 추천합니다.
      - 각 성분에 대해 간결한 해시태그(최대 2개), 한 문장 헤드라인(title), 3~6문장 설명(content)을 제공합니다.

      [출력 형식(중요)]
      - JSON 배열만 출력하세요. 다른 텍스트/코드블록/주석 금지.
      - 각 원소 스키마:
        - id: string (영문 스네이크/케밥 케이스, 고유)
        - name: string (한국어 성분명, 예: "아연")
        - hashtags: string[] (0~2개, 짧은 근거 키워드, 예: "면역 기능", "간 건강")
        - title: string (한 문장 요약, 확정 표현 금지: "~에 도움을 줄 수 있음" 톤)
        - content: string (이유/권장량 범위/식품 급원/주의·금기 포함, 3~6문장, 단위 표기)

      [품질 규칙]
      - 과대광고·확정적 표현 금지(“~에 도움을 줄 수 있음”).
      - 금기(알레르기/질환/복용약)와 중복 효능 회피(예: 오메가3 vs 크릴오일 동시 추천 지양).
      - 식품 급원 1~2개 예시 포함(예: 굴, 붉은살코기 등).
      - 불확실하거나 위험 신호 시 “전문의 상담 권고” 문구 포함.

      [금지]
      - description, positiveKeywords, negativeKeywords 등 스키마 외 필드 출력 금지.
      - 제품/브랜드 추천 금지.

      \(demoBlock)

      [사용자]
      - 대상: \(display)

      [최종 지시]
      - 오직 유효한 JSON 배열 **문자열만** 반환하세요. 앞뒤 설명/마크다운/코드블록을 절대 추가하지 마세요.
      """
  }

  func load(userName: String? = "@@") {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil

    Task {
      do {
        let raw = try await client.request(content: prompt(userName: userName))
        let cleaned = raw
          .replacingOccurrences(of: "```json", with: "")
          .replacingOccurrences(of: "```", with: "")
          .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8) else {
          throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "인코딩 오류"])
        }

        let aiItems = try JSONDecoder().decode([AINutrient].self, from: data)
        let mapped = toNutrients(aiItems)

        self.recommend = mapped
        self.chip = mapped.map { $0.name }
      } catch {
        self.errorMessage = "추천을 불러오지 못했어요."
      }
      self.isLoading = false
    }
  }
}

