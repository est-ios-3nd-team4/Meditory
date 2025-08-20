import Foundation

// 이미지만 구글에서 가지고오기
protocol ImageSearchService {
  func fetchImageAndLink(for brand: String, name: String) async throws -> ImageResult?
}

struct ImageResult {
  let imageURL: String
  let productLink: String
}

actor ImageCache {
  private var cache: [String: ImageResult] = [:]

  func get(_ key: String) -> ImageResult? {
    return cache[key]
  }

  func set(_ key: String, value: ImageResult) {
    if cache.count > 200 {
      cache.removeAll(keepingCapacity: true)
    }
    cache[key] = value
  }
}

final class GoogleCSEImageClient: ImageSearchService {
  let apiKey: String

  let cx: String

  let session: URLSession

  private let imageCache = ImageCache()

  let titleParser: TitleParsing

  init(apiKey: String = GoogleKey.apiKey,
       cx: String = GoogleKey.cx, titleParser: TitleParsing = DefaultTitleParser(), session: URLSession? = nil) {
    self.apiKey = apiKey
    self.cx = cx
    self.titleParser = titleParser

    if let session {
      self.session = session
    } else {
      let conf = URLSessionConfiguration.default
      conf.waitsForConnectivity = true
      conf.timeoutIntervalForRequest = 30
      conf.timeoutIntervalForResource = 60
      self.session = URLSession(configuration: conf)
    }
  }

  func fetchImageAndLink(for brand: String, name: String) async throws -> ImageResult? {
    guard !apiKey.isEmpty, !cx.isEmpty else {
      print("Google API Key 또는 CX 없음 — 이미지 검색 건너뜀")
      return nil
    }
    let endpoint = SearchEndpoint.cseImage(brand: brand, name: name, apiKey: apiKey, cx: cx)

    guard let request = endpoint.makeURLRequest(),
          let cacheKey = request.url?.absoluteString else {
      throw CSEError.badURL
    }

    if let cached = await imageCache.get(cacheKey) {
      return cached
    }

    let (data, resp) = try await session.data(for: request)

    let code = (resp as? HTTPURLResponse)?.statusCode ?? -1

    guard code == 200  else {
      let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
#if DEBUG
      print("[CSE] HTTP \(code)\n\(body)")
#endif
      throw CSEError.http(status: code, body: body)
    }

    do {
      let res = try JSONDecoder().decode(ImageSearchResponse.self, from: data)
      guard let item = res.items?.first,
            let imageURL = item.link ?? item.image?.thumbnailLink,
            let productLink = item.image?.contextLink else {
        return nil
      }

      let result = ImageResult(imageURL: imageURL, productLink: productLink)

      await imageCache.set(cacheKey, value: result)

      return result
    } catch {
      throw CSEError.decode(error)
    }
  }
}

struct ImageSearchResponse: Decodable {
  let items: [ImageItem]?
}

struct ImageItem: Decodable {
  let link: String?
  let image: ImageInfo?
}

struct ImageInfo: Decodable {
  let contextLink: String?
  let thumbnailLink: String?
}

struct ProductSummary {
  var imageURL: String?
  var brand: String?
  var name: String?
  var link: String?
}



