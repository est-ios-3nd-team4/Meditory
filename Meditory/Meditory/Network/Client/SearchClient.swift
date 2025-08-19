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

    let rawQuery = "\"\(brand)\" \"\(name)\""
    let query = rawQuery
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()

    if let cached = await imageCache.get(query) {
          return cached
        }

    var comps = URLComponents(string: "https://www.googleapis.com/customsearch/v1")!
    comps.queryItems = [
      .init(name: "key", value: apiKey),
      .init(name: "cx",  value: cx),
      .init(name: "q",   value: query),
      .init(name: "searchType", value: "image"),
      .init(name: "num", value: "1"),
      .init(name: "gl",  value: "kr"),
      .init(name: "hl",  value: "ko"),
      .init(name: "fields", value: "items(link,image/contextLink,image/thumbnailLink)")
    ]
    guard let url = comps.url else { throw CSEError.badURL }

    let (data, resp) = try await session.data(from: url)

    let str = String(data: data, encoding: .utf8)

    let code = (resp as? HTTPURLResponse)?.statusCode ?? -1

    if code != 200 {
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

      await imageCache.set(query, value: result)

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



