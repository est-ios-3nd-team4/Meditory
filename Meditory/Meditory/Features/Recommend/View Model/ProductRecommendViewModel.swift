import Foundation

final class ProductRecommendViewModel: ObservableObject {
  @Published var products: [Product] = []

  private let client = AlanAPIClient()
  private let googleClient = GoogleCSEImageClient()
  private struct CacheEntry { let products: [Product]; let cachedAt: Date }
  private static var cache: [String: CacheEntry] = [:]
  private static var inFlight: [String: Task<[Product], Error>] = [:]
  private static let ttl: TimeInterval = 60 * 60 * 12

  private func cacheKey(_ category: String) -> String {
    "product-reco:\(category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())"
  }

  private func cleanJSON(_ rawJSONString: String) -> String {
    rawJSONString
      .replacingOccurrences(of: "```json", with: "")
      .replacingOccurrences(of: "```", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }

  // force: true 면 캐시/진행중 요청 무시하고 새로 불러오기
  func loadProducts(for category: String, force: Bool = false) async {
    let categoryCacheKey = cacheKey(category)

    if force {
      Self.inFlight[categoryCacheKey]?.cancel()
      Self.inFlight[categoryCacheKey] = nil
    }

    // 1) 캐시 HIT
    if let cachedEntry = Self.cache[categoryCacheKey],
       Date().timeIntervalSince(cachedEntry.cachedAt) < Self.ttl,
       !force {
      await MainActor.run { self.products = cachedEntry.products }
      return
    }

    // 2) 같은 키의 요청이 이미 진행중이면 그 결과에 합류
    if let existingInFlightTask = Self.inFlight[categoryCacheKey], !force {
      do {
        let resolvedProducts = try await existingInFlightTask.value
        await MainActor.run { self.products = resolvedProducts }
      } catch is CancellationError {
        // 취소됨(무시)
      } catch {
        print("inFlight error:", error)
      }
      return
    }

    // 3) 새 요청 시작
    let fetchTask = Task<[Product], Error> { [client] in
      let prompt = makePrompt(for: category)
      let rawJSONString = try await client.request(content: prompt)
      let jsonString = cleanJSON(rawJSONString)
      guard let jsonData = jsonString.data(using: .utf8) else { return [] }
      let decodedProducts = try JSONDecoder().decode([Product].self, from: jsonData)
      return decodedProducts
    }
    Self.inFlight[categoryCacheKey] = fetchTask

    do {
      let fetchedProducts = try await fetchTask.value
      let finalProducts = await enrichWithImageURLs(products: fetchedProducts)

      await MainActor.run { self.products = finalProducts }
      Self.cache[categoryCacheKey] = CacheEntry(products: finalProducts, cachedAt: Date())
    } catch is CancellationError {
      // 새로고침 등으로 취소 — 무시
    } catch {
      print("fetch error:", error)
    }

    Self.inFlight[categoryCacheKey] = nil
  }

  // MARK: - 기존 메서드들
  private func makePrompt(for category: String) -> String {
    """
    다음과 같은 건강/영양제 카테고리에 적절한 제품(최소 6개 이상 최대 10개 이하)을 추천해줘.
    단, 추천하는 제품은 반드시 아래 사이트들에서 실제 판매 중인 브랜드와 제품명을 사용해야 해.

    허용된 사이트:
    - iherb.com
    - coupang.com
    - smartstore.naver.com
    - lotteon.com
    - lotteimall.com
    - cjmall.com
    - gsshop.com
    - hyundaihmall.com

    카테고리: "\(category)"

    출력 형식은 아래 JSON 배열 형태로만 출력해줘.
    설명이나 텍스트 없이, 백틱 없이 순수 JSON만 반환해줘:

    [
      { "brand": "브랜드명", "name": "제품명" }
    ]
    """
  }

  private func enrichWithImageURLs(products: [Product]) async -> [Product] {
    await withTaskGroup(of: Product?.self) { group in
      for product in products {
        group.addTask {
          do {
            if let imageResult = try await self.googleClient.fetchImageAndLink(for: product.brand, name: product.name) {
              var updated = product
              updated.imageName = imageResult.imageURL
              updated.link = imageResult.productLink
              return updated
            } else {
              return product
            }
          } catch {
            print(error)
            return product
          }
        }
      }
      var enrichedProducts: [Product] = []
      for await enriched in group {
        if let product = enriched { enrichedProducts.append(product) }
      }
      return enrichedProducts
    }
  }
}
