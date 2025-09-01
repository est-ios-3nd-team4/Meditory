import Foundation

/// 연령대/성별 기반으로 추천 영양 성분 칩을 제공하는 뷰모델.
/// - AlanAPIClient를 통해 AI로부터 추천을 받아오고, 캐시 및 inFlight 요청 관리 기능을 포함한다.
@MainActor
final class SearchViewModel: ObservableObject {
  /// UI에 표시할 영양 성분 칩 (텍스트)
  @Published var chips: [String] = []
  /// 로딩 상태
  @Published var isLoading = false
  /// 에러 메시지 (UI에서 표시 가능)
  @Published var errorMessage: String?

  private let client = AlanAPIClient()

  /// API 응답 디코딩용 DTO
  private struct NutrientChipDTO: Codable, Identifiable {
    let id: String
    let name: String
  }

  /// 캐시 엔트리 구조체
  private struct CacheEntry {
    let chips: [String]
    let cachedAt: Date
  }

  /// 캐시 저장소
  private static var cache: [String: CacheEntry] = [:]
  /// 동일한 요청(inFlight)을 합류하기 위한 저장소
  private static var inFlight: [String: Task<[String], Error>] = [:]
  /// 캐시 TTL (12시간)
  private static let ttl: TimeInterval = 60 * 60 * 12

  // MARK: - 캐시 키
  /// 캐시 키 생성 (연령대/성별 조합)
  private func cacheKey(ageGroup: String?, gender: String?) -> String {
    let age = ageGroup ?? "unknown"
    let sex = gender ?? "unknown"
    return "nutrient-chips:\(age)-\(sex)".lowercased()
  }

  // MARK: - 프롬프트 빌더
  /// AI에게 전달할 프롬프트를 생성한다.
  /// - Parameter user: 사용자 정보
  private func prompt(user: User) -> String {
    let ageText = user.ageGroup
    let genderText = user.gender.isEmpty ? "성별 미상" : user.gender

    return """
      [역할]
      - 당신은 한국 사용자에게 연령대와 성별을 기반으로 영양 성분을 추천하는 영양 코치입니다.
      
      [목표]
      - 사용자 정보(연령대, 성별)를 바탕으로 10개 이상의 영양 성분 "이름만" 추천합니다.
      - JSON 배열만 출력하세요.
      - 각 항목은 { "id": "...", "name": "..." } 형식입니다.
      
      [사용자]
      - 연령대: \(ageText)
      - 성별: \(genderText)
      """
  }

  // MARK: - Public
  /// 사용자 정보를 바탕으로 추천 칩 로드
  /// - Parameters:
  ///   - user: 현재 사용자
  ///   - force: true면 캐시/진행중 요청 무시하고 새로 요청
  func load(user: User, force: Bool = false) {
    let key = cacheKey(ageGroup: user.ageGroup, gender: user.gender)

    if let entry = Self.cache[key],
       Date().timeIntervalSince(entry.cachedAt) < Self.ttl,
       !force {
      self.chips = entry.chips
      return
    }

    // 동일한 inFlight 있으면 합류
    if let task = Self.inFlight[key], !force {
      isLoading = true
      Task { @MainActor in
        do { self.chips = try await task.value }
        catch { self.errorMessage = "추천을 불러오지 못했어요." }
        isLoading = false
      }
      return
    }

    isLoading = true
    let task = Task<[String], Error> { [client] in
      let raw = try await client.request(content: prompt(user: user))
      let cleaned = raw
        .replacingOccurrences(of: "```json", with: "")
        .replacingOccurrences(of: "```", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

      guard let data = cleaned.data(using: .utf8) else {
        throw NSError(domain: "AI", code: -1,
                      userInfo: [NSLocalizedDescriptionKey: "인코딩 오류"])
      }

      let decoded = try JSONDecoder().decode([NutrientChipDTO].self, from: data)
      return decoded.map { $0.name }
    }

    Self.inFlight[key] = task

    Task {
      defer { Self.inFlight[key] = nil; self.isLoading = false }
      do {
        let result = try await task.value
        self.chips = result
        Self.cache[key] = CacheEntry(chips: result, cachedAt: Date())
      } catch {
        self.errorMessage = "추천을 불러오지 못했어요."
      }
    }
  }
}

extension User {
  /// 사용자의 연령대 (예: "20대", "30대", "40대")
  var ageGroup: String {
    let calendar = Calendar.current
    let now = Date()
    let age = calendar.dateComponents([.year], from: birthDate, to: now).year ?? 0
    let decade = (age / 10) * 10
    return "\(decade)대"
  }
}
