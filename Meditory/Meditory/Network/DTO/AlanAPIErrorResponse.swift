//
//  AlanAPIErrorResponse.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

struct AlanAPIErrorResponse: Decodable {
    struct Detail: Decodable {
        let loc: [String]
        let msg: String
        let type: String
    }
    
    let detail: [Detail]
}
