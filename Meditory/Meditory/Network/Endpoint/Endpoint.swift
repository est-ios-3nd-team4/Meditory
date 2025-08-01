//
//  Endpoint.swift
//  Meditory
//
//  Created by 홍승아 on 8/1/25.
//

import Foundation

protocol Endpoint {
    func makeURLRequest() -> URLRequest?
}
