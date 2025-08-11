import Foundation

protocol ImageSearchService {
  func firstImageURL(for brand: String, name: String) async throws -> String?
}

final class GoogleCSEImageClient: ImageSearchService {
  private let apiKey: String

  private let cx: String

  private let session: URLSession

  private var cache: [String: String] = [:]   // 간단 캐시

  init(apiKey: String = GoogleKey.apiKey,
       cx: String = GoogleKey.cx) {
    self.apiKey = apiKey
    self.cx = cx
    let conf = URLSessionConfiguration.default
    conf.waitsForConnectivity = true
    conf.timeoutIntervalForRequest = 30
    conf.timeoutIntervalForResource = 60
    self.session = URLSession(configuration: conf)
  }

  func firstImageURL(for brand: String, name: String) async throws -> String? {
    guard !apiKey.isEmpty, !cx.isEmpty else {
      print("CSE key prefix:", GoogleKey.apiKey.prefix(8), "cx:", GoogleKey.cx)
      return nil
    }
    let q = "\"\(brand)\" \"\(name)\""
    if let hit = cache[q] { return hit }

    var u = URLComponents(string: "https://www.googleapis.com/customsearch/v1")!
    u.queryItems = [
      .init(name: "key", value: apiKey),
      .init(name: "cx",  value: cx),
      .init(name: "q",   value: q),
      .init(name: "searchType", value: "image"),
      .init(name: "num", value: "1"),
      .init(name: "gl",  value: "kr"),
      .init(name: "hl",  value: "ko")
    ]

    let (data, resp) = try await session.data(from: u.url!)
    guard let http = resp as? HTTPURLResponse else { return nil }

    if http.statusCode != 200 {
      let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
      print("[CSE] HTTP \(http.statusCode)\n\(body)")
      return nil
    }

    guard (resp as? HTTPURLResponse)?.statusCode == 200 else { return nil }

    let res = try JSONDecoder().decode(ImageSearchResponse.self, from: data)

    let url = res.items?.first?.link ?? res.items?.first?.image?.thumbnailLink

    if let url { cache[q] = url }
    return url
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
