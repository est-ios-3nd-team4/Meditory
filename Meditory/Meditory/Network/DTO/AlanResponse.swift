//
//  AlanResponse.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

struct AlanResponse: Decodable {
    struct Action: Decodable {
        let name: String
        let speak: String
    }
    
    let action: Action
    let content: String
}
