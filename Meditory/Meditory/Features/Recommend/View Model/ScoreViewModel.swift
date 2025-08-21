import Foundation

@MainActor
final class ScoreViewModel: ObservableObject {
  @Published var result: ScoreResult?
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let client = AlanAPIClient()

  func loadMockIntake(weights: ScoreWeights = .default) {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil

    let diet = DietInput(
      foods: ["연어","닭가슴살","잡곡밥","시금치","김치","라면","탄산음료"],
      patterns: ["가공식품 자주","외부 활동 적음"]
    )
    let supplements = SupplementInput(items: [
      SupplementItem(name: "오메가-3", dose: "1000mg", frequencyPerWeek: 7),
      SupplementItem(name: "비타민 C", dose: "500mg",  frequencyPerWeek: 5)
    ])

    Task {
      defer { self.isLoading = false }
      do {
        let prompt = buildIntakeAnalysisPrompt(diet: diet, supplements: supplements)
        let raw = try await client.request(content: prompt)
        guard let json = extractJSON(raw), let data = json.data(using: .utf8) else {
          throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON 추출 실패"])
        }

        let analysis = try JSONDecoder().decode(IntakeAnalysis.self, from: data)

        // 배열 길이로 카운트 산출
        let counts = ScoreCounts(
          deficient: analysis.deficient.count,
          caution:   analysis.caution.count,
          optimal:   analysis.optimal.count,
          adequate:  analysis.adequate.count
        )

        // 점수는 로컬 계산
        let score = computeLocal(counts: counts, weights: weights)

        self.result = ScoreResult(
          score: score,
          counts: counts,
          deficient: dedup(analysis.deficient),
          caution: dedup(analysis.caution),
          optimal: dedup(analysis.optimal),
          adequate: dedup(analysis.adequate),
          summaries: analysis.summaries
        )
      } catch {
        let counts = ScoreCounts(deficient: 0, caution: 0, optimal: 0, adequate: 0)
        self.result = ScoreResult(
          score: 0,
          counts: counts,
          deficient: [],
          caution: [],
          optimal: [],
          adequate: [],
          summaries: AnalysisSummaries(
            deficient: "현재 데이터로 부족 영양성분을 특정하지 못했어요. 식단 다양화와 기본 종합비타민을 고려해보세요.",
            caution: "과다/상호작용 가능성에 유의하세요. 라벨의 1일 권장량(%)을 확인해 주세요.",
            optimal: "일부 성분은 권장량에 잘 맞습니다. 현재 패턴을 유지해 보세요.",
            adequate: "충족 성분은 과하지 않게만 관리하면 됩니다."
          )
        )
        self.errorMessage = "AI 점수 계산 실패 — 로컬 계산으로 대체"
      }
    }
  }

  private func computeLocal(counts: ScoreCounts, weights: ScoreWeights) -> Int {
    let total = counts.deficient + counts.caution + counts.optimal + counts.adequate
    guard total > 0 else { return 0 }
    let raw = weights.base
    + weights.deficient * counts.deficient
    + weights.caution   * counts.caution
    + weights.optimal   * counts.optimal
    + weights.adequate  * counts.adequate
    return max(0, min(100, raw))
  }
  
  private func dedup(_ arr: [String]) -> [String] {
    var seen = Set<String>(), out: [String] = []
    for newScore in arr.map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) }) where !newScore.isEmpty {
      if seen.insert(newScore).inserted { out.append(newScore) }
    }
    return out
  }
}

struct DietInput: Codable, Equatable {
  var foods: [String]
  var patterns: [String]?
}

struct SupplementItem: Codable, Equatable {
  var name: String
  var dose: String?
  var frequencyPerWeek: Int?
}

struct SupplementInput: Codable, Equatable {
  var items: [SupplementItem]
}

struct IntakeAnalysis: Codable, Equatable {
  let deficient: [String]
  let caution:   [String]
  let optimal:   [String]
  let adequate:  [String]
  let summaries: AnalysisSummaries
}

private struct ScorePromptBody: Codable {
  let counts: ScoreCounts
  let weights: ScoreWeights
}

struct AnalysisSummaries: Codable, Equatable {
  let deficient: String
  let caution: String
  let optimal: String
  let adequate: String
}

struct ScoreCounts: Codable, Equatable {
  var deficient: Int
  var caution: Int
  var optimal: Int
  var adequate: Int
}

struct ScoreWeights: Codable, Equatable {
  var deficient: Int
  var caution: Int
  var optimal: Int
  var adequate: Int
  var base: Int

  static let `default` = ScoreWeights(deficient: -12, caution: -7, optimal: 2, adequate: 1, base: 70)
}

struct ScoreResult: Codable, Equatable {
  let score: Int
  let counts: ScoreCounts
  // 카테고리별 칩(영양성분 이름들)
  let deficient: [String]
  let caution: [String]
  let optimal: [String]
  let adequate: [String]
  // 섹션 문단
  let summaries: AnalysisSummaries
}

private func extractJSON(_ raw: String) -> String? {
  if let range = raw.range(of: #"(?s)\{.*\}"#, options: .regularExpression) {
    return String(raw[range])
  }
  return nil
}

private func buildIntakeAnalysisPrompt(diet: DietInput, supplements: SupplementInput) -> String {
  struct Body: Codable { let diet: DietInput; let supplements: SupplementInput }
  let enc = JSONEncoder(); enc.outputFormatting = [.withoutEscapingSlashes]
  let inputJSON = String(data: try! enc.encode(Body(diet: diet, supplements: supplements)), encoding: .utf8)!

  let allowList = [
    "비타민 D","식이섬유","엽산","철분","마그네슘","아연","칼슘",
    "오메가-3","비타민 C","비타민 B군","코엔자임Q10","셀레늄",
    "루테인","아스타잔틴","프로바이오틱스","비타민 K2","콜린"
  ].joined(separator: "\", \"")

  return """
  [역할]
  - 당신은 '식단/영양제 복용 기반 분류기'입니다. 입력을 근거로
    부족/주의/최적/충족 카테고리의 대표 '영양성분명' 칩과 한국어 요약 문단을 JSON으로만 반환합니다.
  - 의료적 진단/처방이 아닌 일반 정보 제공.
  
  [입력]
  \(inputJSON)
  
  [분류 지침]
  - deficient: 결핍 가능성 높은 성분
  - caution: 과다/상호작용/특정 상황 유의 성분
  - optimal: 충분히 잘 섭취 중
  - adequate: 권장량 근처로 무난히 충족
  - 성분명만 사용(브랜드/질환/문장 금지), 한국어 표기, 중복 금지.
  
  [칩 규칙]
  - 각 배열은 상황에 따라 0~6개. 너무 빈약하면 아래 allowlist로 최대 3개까지 보충(중복 없이).
    allowlist = ["\(allowList)"]
  
  [요약 규칙]
  - summaries 각 문단은 한국어 1~2문장, 일반 조언(과장/진단/치료 금지).
  
  [출력 제약]
  - **오직 JSON 객체 1개**만 출력(설명/코드블록/사과문 금지).
  
  [출력 스키마]
  {
    "deficient": [<string>],
    "caution":   [<string>],
    "optimal":   [<string>],
    "adequate":  [<string>],
    "summaries": {
      "deficient": <string>,
      "caution":   <string>,
      "optimal":   <string>,
      "adequate":  <string>
    }
  }
  """
}
