//
//  Bundle+Extension.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import Foundation

extension Bundle {
    var FirebaseKey: String? {
        return infoDictionary?["API_KEY"] as? String
    }
}
