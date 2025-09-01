import Foundation
import CryptoKit

// MARK: - 내부 입력 모델
/// 사용자 프로필 입력값 (AI 프롬프트용)
private struct ProfileInput: Codable {
  let name: String
  let ageGroup: String?
  let gender: String?
}

/// 총 섭취량 입력값 (탄수/단백질/지방, AI 프롬프트용)
private struct MacroTotalsInput: Codable {
  let carbohydrate: Int
  let protein: Int
  let fat: Int
}

/// 식단 맥락 입력값 (요약/기간 포함, AI 프롬프트용)
private struct MealContextInput: Codable {
  let windowDays: Int
  let summaryLines: [String]
  let macroTotals: MacroTotalsInput
}

// MARK: - ViewModel
/// 식단과 사용자 정보를 바탕으로 AI 분석 점수(ScoreResult)를 계산하는 뷰모델
@MainActor
final class ScoreViewModel: ObservableObject {
  /// 최종 분석 결과
  @Published var result: ScoreResult?
  /// 로딩 상태
  @Published var isLoading = false
  /// 에러 메시지
  @Published var errorMessage: String?

  private let client = AlanAPIClient()

  /// 캐시 엔트리 구조체
  private struct CacheEntry {
    let result: ScoreResult
    let cachedAt: Date
  }

  /// 캐시 (입력 조건 → ScoreResult)
  private static var cache: [String: CacheEntry] = [:]
  /// 현재 진행 중인 요청 (중복 호출 방지)
  private static var inFlight: [String: Task<ScoreResult, Error>] = [:]
  /// 캐시 TTL (12시간)
  private static let ttl: TimeInterval = 60 * 60 * 12

  // MARK: - 캐시 키
  /// 캐시 키 생성 (식단/가중치/기간/지문 포함)
  private func cacheKey(diet: DietInput,
                        weights: ScoreWeights,
                        meals: [Meal],
                        windowDays: Int) -> String {
    struct KeyBody: Codable {
      let diet: DietInput
      let weights: ScoreWeights
      let mealFingerprint: String
      let windowDays: Int
    }
    
    let fingerprint = mealFingerprint(meals)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
    let data = (try? encoder.encode(
      KeyBody(diet: diet,
              weights: weights,
              mealFingerprint: fingerprint,
              windowDays: windowDays)
    )) ?? Data()
    let json = String(data: data, encoding: .utf8) ?? ""
    return "score:\(json)"
  }

  // MARK: - Public
  /// 점수 로드
  /// - Parameters:
  ///   - diet: 입력 식단
  ///   - meals: 식사 기록
  ///   - user: 사용자 정보
  ///   - windowDays: 분석 기간(일 단위)
  ///   - weights: 가중치
  ///   - force: true면 캐시/진행중 요청 무시하고 새로 호출
  func load(diet: DietInput,
            meals: [Meal],
            user: User?,
            windowDays: Int = 30,
            weights: ScoreWeights = .default,
            force: Bool = false) {
    
    let key = cacheKey(diet: diet,
                       weights: weights,
                       meals: meals,
                       windowDays: windowDays)
    
    if force {
      Self.inFlight[key]?.cancel()
      Self.inFlight[key] = nil
    }
    
    if let entry = Self.cache[key],
       Date().timeIntervalSince(entry.cachedAt) < Self.ttl,
       !force {
      self.result = entry.result
      self.isLoading = false
      self.errorMessage = nil
      return
    }
    
    if let inFlightTask = Self.inFlight[key], !force {
      self.isLoading = true
      self.errorMessage = nil
      Task { [weak self] in
        guard let self else { return }
        defer { self.isLoading = false }
        do {
          let value = try await inFlightTask.value
          self.result = value
        } catch is CancellationError {
          // 취소 무시
        } catch {
          self.errorMessage = "계산 실패"
        }
      }
      return
    }
    
    self.isLoading = true
    self.errorMessage = nil
    
    let newTask = Task<ScoreResult, Error> { [client] in
      let prompt = buildIntakeAnalysisPrompt(diet: diet,
                                             meals: meals,
                                             user: user,
                                             windowDays: windowDays)
      let raw = try await client.request(content: prompt)
      guard let json = extractJSON(raw), let data = json.data(using: .utf8) else {
        throw NSError(domain: "AI", code: -1, userInfo: [NSLocalizedDescriptionKey: "JSON 추출 실패"])
      }
      
      let analysis = try JSONDecoder().decode(IntakeAnalysis.self, from: data)
      
      let counts = ScoreCounts(
        deficient: analysis.deficient.count,
        caution:   analysis.caution.count,
        optimal:   analysis.optimal.count,
        adequate:  analysis.adequate.count
      )
      
      let score = computeLocal(counts: counts, weights: weights)
      
      return ScoreResult(
        score: score,
        counts: counts,
        deficient: dedup(analysis.deficient),
        caution:   dedup(analysis.caution),
        optimal:   dedup(analysis.optimal),
        adequate:  dedup(analysis.adequate),
        summaries: analysis.summaries
      )
    }
    
    Self.inFlight[key] = newTask
    
    Task { [weak self] in
      guard let self else { return }
      defer { Self.inFlight[key] = nil; self.isLoading = false }
      do {
        let resultValue = try await newTask.value
        self.result = resultValue
        Self.cache[key] = CacheEntry(result: resultValue, cachedAt: Date())
      } catch is CancellationError {
        // 취소 무시
      } catch {
        self.errorMessage = "계산 실패"
        self.result = nil
      }
    }
  }

  // MARK: - Local 계산/후처리
  /// 로컬 점수 계산 (가중치 적용)
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

// MARK: - Helper 함수
/// 식단 컨텍스트 생성
private func makeMealContext(meals: [Meal], windowDays: Int) -> MealContextInput {
  let sortedMeals = meals.sorted { $0.date < $1.date }
  let lines = sortedMeals.map { $0.nutritionSummaryLine }
  let totals = meals.macroTotals
  let macroTotals = MacroTotalsInput(
    carbohydrate: Int(totals.carb.rounded()),
    protein: Int(totals.protein.rounded()),
    fat: Int(totals.fat.rounded())
  )
  return MealContextInput(windowDays: windowDays, summaryLines: lines, macroTotals: macroTotals)
}

/// Meal fingerprint 생성 (날짜/매크로/대표 음식 기준)
private func mealFingerprint(_ meals: [Meal]) -> String {
  // 날짜/매크로/대표 음식명 기준
  let sorted = meals.sorted { $0.date < $1.date }
  let raw = sorted.map { m in
    let foodsText = m.foods.prefix(3).map { $0.foodName }.joined(separator: ",")
    return "\(m.date.timeIntervalSince1970.rounded())|\(Int(m.carbohydrateTotal))|\(Int(m.proteinTotal))|\(Int(m.fatTotal))|\(foodsText)"
  }.joined(separator: "||")
  let digest = SHA256.hash(data: Data(raw.utf8))
  return digest.map { String(format: "%02x", $0) }.joined()
}

// MARK: - 데이터 모델
/// 사용자 입력 식단
struct DietInput: Codable, Equatable {
  var foods: [String]
  var patterns: [String]?
}

/// AI가 반환하는 분석 결과
struct IntakeAnalysis: Codable, Equatable {
  let deficient: [String]
  let caution:   [String]
  let optimal:   [String]
  let adequate:  [String]
  let summaries: AnalysisSummaries
}

/// AI 프롬프트용 점수 입력 스키마
private struct ScorePromptBody: Codable {
  let counts: ScoreCounts
  let weights: ScoreWeights
}

/// 카테고리별 요약 문단
struct AnalysisSummaries: Codable, Equatable {
  let deficient: String
  let caution: String
  let optimal: String
  let adequate: String
}

/// 카테고리별 성분 개수
struct ScoreCounts: Codable, Equatable {
  var deficient: Int
  var caution: Int
  var optimal: Int
  var adequate: Int
}

/// 가중치
struct ScoreWeights: Codable, Equatable {
  var deficient: Int
  var caution: Int
  var optimal: Int
  var adequate: Int
  var base: Int
  
  static let `default` = ScoreWeights(deficient: -12, caution: -7, optimal: 2, adequate: 1, base: 70)
}

/// 최종 점수 결과
struct ScoreResult: Codable, Equatable {
  let score: Int
  let counts: ScoreCounts
  /// 카테고리별 성분 이름들
  let deficient: [String]
  let caution: [String]
  let optimal: [String]
  let adequate: [String]
  /// 카테고리별 요약 문단
  let summaries: AnalysisSummaries
}

// MARK: - JSON 처리
/// 문자열에서 JSON 객체 부분 추출
private func extractJSON(_ raw: String) -> String? {
  if let range = raw.range(of: #"(?s)\{.*\}"#, options: .regularExpression) {
    return String(raw[range])
  }
  return nil
}

/// 식단 분석 프롬프트 빌드
private func buildIntakeAnalysisPrompt(diet: DietInput,
                                       meals: [Meal],
                                       user: User?,
                                       windowDays: Int) -> String {
  let displayNameRaw = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  let displayName = displayNameRaw.isEmpty ? "사용자" : displayNameRaw
  let profile = ProfileInput(
    name: displayName,
    ageGroup: user?.ageGroup,                      // User.ageGroup 확장 사용
    gender: user?.gender.isEmpty == false ? user!.gender : nil
  )
  let mealContext = makeMealContext(meals: meals, windowDays: windowDays)
  
  struct InputBody: Codable {
    let profile: ProfileInput
    let diet: DietInput
    let mealContext: MealContextInput
  }
  
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.withoutEscapingSlashes]
  
  let inputJSON = (try? encoder.encode(
    InputBody(profile: profile, diet: diet, mealContext: mealContext)
  )).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
  
  let allowList = [
    "비타민 D","식이섬유","엽산","철분","마그네슘","아연","칼슘",
    "오메가-3","비타민 C","비타민 B군","코엔자임Q10","셀레늄",
    "루테인","아스타잔틴","프로바이오틱스","비타민 K2","콜린"
  ].joined(separator: "\", \"")
  
  return """
  [역할]
  - 당신은 '식단/영양제 기반 분류기'입니다. **mealContext(실제 식단)**를 최우선 근거로,
    diet.foods/patterns는 보조 단서로 활용합니다.
  - 의료적 진단/처방이 아닌 일반 정보 제공.
  
  [입력(JSON)]
  \(inputJSON)
  
  [분류 지침]
  - deficient: 결핍 가능성 높은 성분 (식단 부족, 패턴, 햇빛 노출 등 고려)
  - caution: 과다/상호작용/특정 상황 유의 성분 (예: 혈액응고제 + 오메가-3)
  - optimal: 충분히 잘 섭취 중
  - adequate: 권장량 근처로 무난히 충족
  - 성분명만 사용(브랜드/질환/문장 금지), 한국어 표기, 중복 금지.
  - 만약 mealContext.summaryLines가 비어 있다면,
    한국인에게 일반적으로 부족하기 쉬운 대표 성분 3개(예: 비타민 D, 식이섬유, 오메가-3)를 deficient에 넣으세요.
  - 나머지 배열은 빈 배열([])로 두어도 됩니다.
  
  [칩 규칙]
  - 각 배열은 상황에 따라 0~6개. 빈약하면 아래 allowlist로 최대 3개 보충(중복 없이).
    allowlist = ["\(allowList)"]
  
  [요약 규칙]
  - summaries 각 문단은 한국어 3~4문장, 일반 조언(과장/진단/치료 금지).
  - 식단 총섭취(탄/단/지)와 음식 리스트를 간단히 근거로 포함.
  
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
