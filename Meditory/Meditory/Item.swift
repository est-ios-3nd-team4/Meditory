//
//  Item.swift
//  Meditory
//
//  Created by 윤혜주 on 7/30/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
