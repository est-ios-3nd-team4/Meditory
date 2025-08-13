import Foundation

// 이미지만 구글에서 가지고오기
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
      print("Google API Key 또는 CX 없음 — 이미지 검색 건너뜀")
      return nil
    }

    let rawQuery = "\"\(brand)\" \"\(name)\""
    let query = rawQuery
      .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .lowercased()

    if let hit = cache[query] { return hit }

    var comps = URLComponents(string: "https://www.googleapis.com/customsearch/v1")!
    comps.queryItems = [
      .init(name: "key", value: apiKey),
      .init(name: "cx",  value: cx),
      .init(name: "q",   value: query),
      .init(name: "searchType", value: "image"),
      .init(name: "num", value: "1"),
      .init(name: "gl",  value: "kr"),
      .init(name: "hl",  value: "ko"),
      .init(name: "fields", value: "items(link,image/thumbnailLink)")
    ]
    guard let url = comps.url else { throw CSEError.badURL }

    let (data, resp) = try await session.data(from: url)
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
      let url = res.items?.first?.link ?? res.items?.first?.image?.thumbnailLink
      if let url {
        if cache.count > 200 { cache.removeAll(keepingCapacity: true) }
        cache[query] = url
      }
      return url
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

private func cleanTitle(_ raw: String) -> String {
  var titleFromItem = raw
  let separators = ["|", "-", ".", "-", ":", "•"]
  for sep in separators {
    if let range = titleFromItem.range(of: sep) {
      titleFromItem = String(titleFromItem[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
      break
    }
  }

  titleFromItem = titleFromItem.replacingOccurrences(of: "Pillyze", with: "", options: .caseInsensitive)
    .trimmingCharacters(in: .whitespacesAndNewlines)
  return titleFromItem
}

private func cleanPillyzeTitle(_ raw: String) -> String {
    var title = raw.trimmingCharacters(in: .whitespacesAndNewlines)

    let removableSuffixes = [
        " - 필라이즈", " | 필라이즈", " · 필라이즈",
        " - Pillyze", " | Pillyze", " · Pillyze", " • Pillyze"
    ]

    for suffix in removableSuffixes {
        if let suffixRange = title.range(of: suffix, options: [.caseInsensitive, .backwards]) {
            title.removeSubrange(suffixRange)
            break
        }
    }
    return title.trimmingCharacters(in: .whitespacesAndNewlines)
}

/// 제목/메타에서 brand & name 추출
private func extractBrandAndName(fromTitle rawTitle: String, metaBrand: String?) -> (brand: String?, name: String?) {
    // 1) 메타 brand 최우선
    if let metaBrandTrimmed = metaBrand?.trimmingCharacters(in: .whitespacesAndNewlines),
       !metaBrandTrimmed.isEmpty {

        let cleanedTitle = cleanPillyzeTitle(rawTitle)

        // [브랜드] 제품명 형태 제거
        let titleWithoutBracket = cleanedTitle.replacingOccurrences(
            of: #"^\[\s*\Q\#(metaBrandTrimmed)\E\s*\]\s*"#,
            with: "",
            options: .regularExpression
        )

        // "브랜드 구분자 제품명" 형태 제거
        let titleWithoutPrefix = titleWithoutBracket.replacingOccurrences(
            of: #"^\Q\#(metaBrandTrimmed)\E\s*[\-\|\:\•]\s*"#,
            with: "",
            options: .regularExpression
        )

        let extractedName = titleWithoutPrefix.trimmingCharacters(in: .whitespacesAndNewlines)

        return (metaBrandTrimmed, extractedName.isEmpty ? cleanedTitle : extractedName)
    }

    // 2) [브랜드] 제품명
    let cleanedTitle = cleanPillyzeTitle(rawTitle)
    if let brandNameMatchRange = cleanedTitle.range(of: #"^\s*\[(.+?)\]\s*(.+)$"#, options: .regularExpression) {
        let matchedString = String(cleanedTitle[brandNameMatchRange])

        if let brandRange = matchedString.range(of: #"(?<=^\s*\[).+?(?=\]\s*)"#, options: .regularExpression),
           let nameRange = matchedString.range(of: #"(?<=\]\s*).+$"#, options: .regularExpression) {

            let extractedBrand = String(matchedString[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let extractedName = String(matchedString[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            return (extractedBrand.isEmpty ? nil : extractedBrand,
                    extractedName.isEmpty ? nil : extractedName)
        }
    }

    // 3) 브랜드 구분자 제품명 ( -, |, :, • )
    if let brandSeparatorMatchRange = cleanedTitle.range(of: #"^(.+?)\s*[\-\|\:\•]\s*(.+)$"#, options: .regularExpression) {
        let matchedString = String(cleanedTitle[brandSeparatorMatchRange])

        if let brandRange = matchedString.range(of: #"^.+?(?=\s*[\-\|\:\•])"#, options: .regularExpression),
           let nameRange = matchedString.range(of: #"(?<=\s*[\-\|\:\•]\s*).+$"#, options: .regularExpression) {

            let extractedBrand = String(matchedString[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let extractedName = String(matchedString[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            return (extractedBrand.isEmpty ? nil : extractedBrand,
                    extractedName.isEmpty ? nil : extractedName)
        }
    }

    // 4) 최후의 수단: 처음 단어를 브랜드로 가정
    if let firstWordBrandMatchRange = cleanedTitle.range(of: #"^([A-Za-z가-힣0-9]{2,20})\s+(.+)$"#, options: .regularExpression) {
        let matchedString = String(cleanedTitle[firstWordBrandMatchRange])

        if let brandRange = matchedString.range(of: #"^[A-Za-z가-힣0-9]{2,20}"#, options: .regularExpression),
           let nameRange = matchedString.range(of: #"(?<=\s).+$"#, options: .regularExpression) {

            let extractedBrand = String(matchedString[brandRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let extractedName = String(matchedString[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            return (extractedBrand.isEmpty ? nil : extractedBrand,
                    extractedName.isEmpty ? nil : extractedName)
        }
    }

    // 실패 시: 브랜드 없음, 전체를 이름으로
    return (nil, cleanedTitle.isEmpty ? nil : cleanedTitle)
}


extension Optional where Wrapped == String {
  var isNilorEmpty: Bool { self?.isEmpty ?? true }

  var nilIfEmpty: String? {
    guard let trimmedText = self?.trimmingCharacters(in: .whitespacesAndNewlines),
          !trimmedText.isEmpty else { return nil }
    return trimmedText
  }
}

// 검색을 위한 필라이즈
extension GoogleCSEImageClient {
  func fetchPillyzePage(query: String, start: Int, num: Int = 10) async throws -> [ProductSummary] {
    print("[DEBUG] fetchPillyzePage query: '\(query)' start: \(start) num: \(num)")

    guard !apiKey.isEmpty, !cx.isEmpty else {
      print("Google API Key 또는 CX 없음 — 이미지 검색 건너뜀")
      return []
    }

    let trimmedQ = query.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmedQ.isEmpty else { throw CSEError.badURL }

    let safeNum = max(1, min(num, 10))
    let safeStart = max(start, 1)

    let base = URL(string: "https://www.googleapis.com/customsearch/v1")!
    var comps = URLComponents(url: base, resolvingAgainstBaseURL: false)!
    comps.queryItems = [
      .init(name: "key", value: apiKey),
      .init(name: "cx", value: cx),
      .init(name: "q", value: trimmedQ),
      .init(name: "num", value: String(safeNum)),
      .init(name: "start", value: String(safeStart)),
      .init(name: "gl", value: "kr"),
      .init(name: "hl", value: "ko"),
      .init(name: "siteSearch", value: "pillyze.com"),
      .init(name: "siteSearchFilter", value: "i"),
      .init(name: "fields", value: "items(link,title,displayLink,pagemap(product(name,brand),cse_image(src),cse_thumbnail(src),imageobject(url),metatags))")
    ]
    guard let url = comps.url else { throw CSEError.badURL }

#if DEBUG
    print("[CSE IMG] \(url.absoluteString)")
#endif

    let (data, resp) = try await session.data(from: url)
    let status = (resp as? HTTPURLResponse)?.statusCode ?? -1
    guard status == 200 else {
      let body = String(data:  data, encoding: .utf8) ?? "<non-utf8>"
      throw CSEError.http(status: status, body: body)
    }

    let response = try JSONDecoder().decode(CSEResponse.self, from: data)

    let products: [ProductSummary] = (response.items ?? [])
      .filter { ($0.link ?? "").contains("/products") }
      .map { item in
        var brand: String? = nil
        var name: String? = nil
        var image: String? = nil

        if let productInfo = item.pagemap?.product?.first {
          if let nameValue = productInfo.name?.trimmingCharacters(in: .whitespacesAndNewlines),
             !nameValue.isEmpty {
            name = nameValue
          }

          let brandValue = productInfo.brand?.value.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
          if !brandValue.isEmpty { brand = brandValue }
        }

        var metaBrand: String? = nil
        if let meta = item.pagemap?.metatags?.first {
          if let metaBrandValue = meta["product:brand"]?.trimmingCharacters(in: .whitespacesAndNewlines), !metaBrandValue.isEmpty {
            metaBrand = metaBrandValue
          }
        }

        let titleRaw = item.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if brand == nil || name == nil {
          let (titleBrand, titleName) = extractBrandAndName(fromTitle: titleRaw, metaBrand: metaBrand)
          if brand == nil { brand = titleBrand }
          if name  == nil { name  = titleName }
        }

        image = item.pagemap?.cseImage?.first?.src
        ?? item.pagemap?.cseThumbnail?.first?.src
        ?? item.pagemap?.imageObject?.first?.url

        return ProductSummary(
          imageURL: image,
          brand: brand,
          name: name,
          link: item.link
        )
      }
    return products
  }
}
