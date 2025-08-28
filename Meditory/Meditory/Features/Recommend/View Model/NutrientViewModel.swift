import Foundation
import SwiftData
import CryptoKit

extension Meal {
  var nutritionSummaryLine: String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm"
    let foodsText = foods.prefix(4).map { $0.foodName }.joined(separator: ", ")
    return "• \(df.string(from: date)) \(mealName) – 탄수 \(Int(carbohydrateTotal))g / 단백질 \(Int(proteinTotal))g / 지방 \(Int(fatTotal))g / 음식: \(foodsText)"
  }
}

extension Collection where Element == Meal {
  var macroTotals: (carb: Double, protein: Double, fat: Double) {
    reduce(into: (0.0, 0.0, 0.0)) { acc, meal in
      acc.carb += meal.carbohydrateTotal
      acc.protein += meal.proteinTotal
      acc.fat += meal.fatTotal
    }
  }
}

@MainActor
final class NutrientViewModel: ObservableObject {
  // UI 바인딩용 (직관적 이름)
  @Published var chips: [String] = []
  @Published var recommendations: [Nutrient] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let client = AlanAPIClient()

  // AI 응답 디코딩 DTO
  private struct NutrientDTO: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    var hashtags: [String]
    let title: String
    let content: String
  }

  // 캐시
  private struct CacheEntry {
    let chips: [String]
    let nutrients: [Nutrient]
    let cachedAt: Date
  }
  private static var cache: [String: CacheEntry] = [:]
  private static var inFlight: [String: Task<(chips: [String], nutrients: [NutrientDTO]), Error>] = [:]
  private static let ttl: TimeInterval = 60 * 60 * 12

  // MARK: - Cache Key (user + meal fingerprint)
  private func makeCacheKey(user: User?, meals: [Meal]) -> String {
    let who = (user?.name ?? user?.displayName ?? "@@").trimmingCharacters(in: .whitespacesAndNewlines)
    let base = who.isEmpty ? "@@" : who
    let fp = mealFingerprint(meals)
    return "nutrients:\(base.lowercased())|\(fp)"
  }

  private func mealFingerprint(_ meals: [Meal]) -> String {
    // 날짜/매크로/대표 음식명으로 간단 지문 생성 → SHA256
    let sorted = meals.sorted { $0.date < $1.date }
    let sig = sorted.map { m in
      let foodsText = m.foods.prefix(3).map { $0.foodName }.joined(separator: ",")
      return "\(m.date.timeIntervalSince1970.rounded())|\(Int(m.carbohydrateTotal))|\(Int(m.proteinTotal))|\(Int(m.fatTotal))|\(foodsText)"
    }.joined(separator: "||")
    let digest = SHA256.hash(data: Data(sig.utf8))
    return digest.map { String(format: "%02x", $0) }.joined()
  }

  // MARK: - 프롬프트 (식단 반영 + 정확히 3개)
  private func buildPrompt(user: User?, meals: [Meal]) -> String {
    let display = (user?.displayName.isEmpty == false ? user!.displayName : (user?.name ?? "사용자"))
    let ageGender: String = {
      if let currentUser = user {
        let ageGroup = currentUser.ageGroup
        let gender = currentUser.gender.isEmpty ? "성별 미상" : currentUser.gender
        return "- 연령대: \(ageGroup)\n- 성별: \(gender)\n"
      }
      return ""
    }()

    let mealLines = meals.isEmpty
      ? "• 최근 식단 기록 없음"
      : meals.map { $0.nutritionSummaryLine }.joined(separator: "\n")

    let totals = meals.macroTotals
    let totalLine = meals.isEmpty
      ? ""
      : "\n[총섭취합계] 탄수 \(Int(totals.carb))g / 단백질 \(Int(totals.protein))g / 지방 \(Int(totals.fat))g"

    return """
    [역할]
    - 당신은 한국 사용자에게 실제 식단을 바탕으로 부족/보완이 필요한 영양 성분을 추천하는 영양 코치입니다.
    - 의학적 진단/처방을 대체하지 않으며, 필요 시 전문의 상담을 권장합니다.

    [사용자]
    - 이름: \(display)
    \(ageGender)
    [식단 요약]
    \(mealLines)
    \(totalLine)

    [목표]
    - 위 식단을 분석하여 "중복되지 않는" 영양 성분을 **정확히 3개** 추천하세요.
    - 각 성분: 해시태그(최대 2), 한 문장 요약(title), 6~10문장 설명(content: 이유/권장량 범위/식품 급원/주의·금기/상호작용/단위 포함).
    - 제품/브랜드 추천 금지.

    [출력 형식(중요)]
    - **유효한 JSON 배열만** 출력하세요. 다른 텍스트/코드블록/주석 금지.
    - 배열 길이는 반드시 3입니다.
    - 각 원소 스키마:
      - id: string (영문 스네이크/케밥 케이스, 고유)
      - name: string (한국어 성분명, 예: "아연")
      - hashtags: string[] (0~2개, 짧은 근거 키워드, 예: "면역 기능", "간 건강")
      - title: string (한 문장 요약, "~에 도움을 줄 수 있음" 톤)
      - content: string (6~10문장, 단위 표기 포함)

    [품질 규칙]
    - 과대광고/확정적 표현 금지(“~에 도움을 줄 수 있음”).
    - 금기(알레르기/질환/복용약) 고려.
    - 유사 원료 동시 추천 금지(예: 오메가3 vs 크릴오일).
    - 식품 급원 1~2가지 예시 포함.
    - 위험 신호 시 “전문의 상담 권고” 문구 포함.

    [검증]
    - 배열 길이는 3이어야 합니다.
    - JSON 앞뒤로 어떤 설명도 붙이지 마세요.
    """
  }

  // MARK: - public: 식단 반영 로드
  func load(user: User?, meals: [Meal], force: Bool = false) {
    let key = makeCacheKey(user: user, meals: meals)

    if let entry = Self.cache[key],
       Date().timeIntervalSince(entry.cachedAt) < Self.ttl, !force {
      self.chips = entry.chips
      self.recommendations = entry.nutrients
      self.isLoading = false
      self.errorMessage = nil
      return
    }

    if let task = Self.inFlight[key], !force {
      isLoading = true
      errorMessage = nil
      Task { @MainActor in
        do {
          let result = try await task.value
          let mapped = result.nutrients.map {
            Nutrient(id: $0.id, name: $0.name, hashtags: $0.hashtags,
                     description: "", title: $0.title, content: $0.content,
                     positiveKeywords: [], negativeKeywords: [])
          }
          self.chips = result.chips
          self.recommendations = mapped
          self.isLoading = false
        } catch {
          self.errorMessage = "식단 기반 추천을 불러오지 못했어요."
          self.isLoading = false
        }
      }
      return
    }

    // 새 요청
    isLoading = true
    errorMessage = nil

    let task = Task<(chips: [String], nutrients: [NutrientDTO]), Error> { [client, user, meals] in
      let raw = try await client.request(content: buildPrompt(user: user, meals: meals))
      let cleaned = raw
        .replacingOccurrences(of: "```json", with: "")
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

      guard let data = cleaned.data(using: .utf8) else {
        throw NSError(domain: "AI", code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "인코딩 오류"])
      }

      var items = try JSONDecoder().decode([NutrientDTO].self, from: data)
      if items.count > 3 { items = Array(items.prefix(3)) }
      guard items.count == 3 else {
        throw NSError(domain: "AI", code: -2,
                      userInfo: [NSLocalizedDescriptionKey: "응답 항목 수가 3개가 아닙니다."])
      }

      return (items.map { $0.name }, items)
    }

    Self.inFlight[key] = task

    Task {
      defer { Self.inFlight[key] = nil; self.isLoading = false }
      do {
        let result = try await task.value
        let mapped = result.nutrients.map {
          Nutrient(id: $0.id, name: $0.name, hashtags: $0.hashtags,
                   description: "", title: $0.title, content: $0.content,
                   positiveKeywords: [], negativeKeywords: [])
        }
        self.chips = result.chips
        self.recommendations = mapped

        Self.cache[key] = CacheEntry(chips: result.chips, nutrients: mapped, cachedAt: Date())
      } catch {
        self.errorMessage = "식단 기반 추천을 불러오지 못했어요."
      }
    }
  }

  // 저장
  func saveRecommendations(to context: ModelContext) {
    do {
      let stored = try context.fetch(FetchDescriptor<Nutrient>())
      var byId: [String: Nutrient] = [:]
      for item in stored { byId[item.id] = item }

      for nutrient in recommendations {
        if let existing = byId[nutrient.id] {
          existing.name = nutrient.name
          existing.hashtags = nutrient.hashtags
          existing.desc = nutrient.desc
          existing.title = nutrient.title
          existing.content = nutrient.content
          existing.positiveKeywords = nutrient.positiveKeywords
          existing.negativeKeywords = nutrient.negativeKeywords
        } else {
          context.insert(nutrient)
        }
      }
      try context.save()
    } catch {
      print(error)
    }
  }
}
