//
//  CSEImage+Pillyze.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/13/25.
//

import Foundation

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
          let (titleBrand, titleName) = titleParser.extractBrandAndName(
            fromTitle: titleRaw,
            metaBrand: metaBrand
          )
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
