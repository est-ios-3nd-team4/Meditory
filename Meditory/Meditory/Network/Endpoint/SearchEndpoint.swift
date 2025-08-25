//
//  SearchEndpoint.swift
//  Meditory
//
//  Created by Jaehun Kim on 8/19/25.
//

import Foundation

enum SearchEndpoint {
  case cseImage(brand: String, name: String, apiKey: String, cx: String)
}

extension SearchEndpoint: Endpoint {
  var baseURL: String { "https://www.googleapis.com/customsearch/v1" }
  var path: String { "" }
  var method: HTTPMethod { .get }

  var queryItems: [URLQueryItem]? {
    switch self {
    case let .cseImage(brand, name, apiKey, cx):
      let rawQuery = "\"\(brand)\" \"\(name)\""
      let query = collapseSpaces(rawQuery)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()

      return [
        URLQueryItem(name: "key", value: apiKey),
        URLQueryItem(name: "cx", value: cx),
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "searchType", value: "image"),
        URLQueryItem(name: "num", value: "1"),
        URLQueryItem(name: "gl", value: "kr"),
        URLQueryItem(name: "hl", value: "ko"),
        URLQueryItem(name: "fields", value: "items(link,image/contextLink,image/thumbnailLink)")
      ]
    }
  }

  func makeURLRequest() -> URLRequest? {
    var components = URLComponents(string: baseURL)
    components?.path += path
    guard let queryItems else { return nil }
    components?.queryItems = queryItems

    guard let url = components?.url else { return nil }

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    return request
  }
}

private func collapseSpaces(_ text: String) -> String {
  text.split { $0.isWhitespace }.joined(separator: " ")
}
