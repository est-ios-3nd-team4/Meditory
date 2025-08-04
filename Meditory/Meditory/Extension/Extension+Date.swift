//
//  Extension+Date.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import Foundation

extension Date {
    var timeFormatter: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "a h:mm"
        return dateFormatter.string(from: self)
    }

    var yearMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        return dateFormatter.string(from: self)
    }

    func formattedDate(_ date: Date, _ format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: date)
    }
}
