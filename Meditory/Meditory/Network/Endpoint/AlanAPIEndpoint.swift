//
//  AlanAPIEndpoint.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

enum AlanAPIEndpoint {
    case question(content: String)
    case questionWithSSE(content: String)
}

extension AlanAPIEndpoint: Endpoint {
    
    var baseURL: String {
        return "https://kdt-api-function.azurewebsites.net/api/v1"
    }
    
    var path: String {
        switch self {
        case .question:
            return "/question"
        case .questionWithSSE:
            return "/question/sse-streaming"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .question, .questionWithSSE:
            return .get
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .question(let content), .questionWithSSE(let content):
            guard let apiKey = APIKey.alan.value else {
                print("AlanAPIKey is missing.")
                return nil
            }
            
            return [
                URLQueryItem(name: "content", value: content),
                URLQueryItem(name: "client_id", value: apiKey),
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
