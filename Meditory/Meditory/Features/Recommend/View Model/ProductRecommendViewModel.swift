import Foundation

final class ProductRecommendViewModel: ObservableObject {
  @Published var products: [Product] = []

  private let client = AlanAPIClient()
  private let googleClient = GoogleCSEImageClient()

  func loadProducts(for category: String) async {
    do {
      let prompt = makePrompt(for: category)

      let jsonString = try await client.request(content: prompt)

      guard let jsonData = jsonString.data(using: .utf8) else { return }

      let decodedProducts = try JSONDecoder().decode([Product].self, from: jsonData)

      let enriched = await enrichWithImageURLs(products: decodedProducts)

      await MainActor.run {
        self.products = enriched
      }
    } catch {
      print(error)
    }
  }

  private func makePrompt(for category: String) -> String {
    return """
      다음과 같은 건강/영양제 카테고리에 적절한 제품(최소 5개이상 최대 10개이하)을 추천해줘.
          각 제품은 브랜드명과 제품명으로 구성해줘.
      
          카테고리: "\(category)"
      
          출력 형식은 아래 JSON 배열 형태로만 출력해줘.
          설명이나 텍스트 없이, 백틱 없이 순수 JSON만 반환해줘:
      
          [
            {
              "brand": "브랜드명",
              "name": "제품명"
            }
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
      var result: [Product] = []
      for await enriched in group {
        if let product = enriched {
          result.append(product)
        }
      }
      return result
    }
  }
}
