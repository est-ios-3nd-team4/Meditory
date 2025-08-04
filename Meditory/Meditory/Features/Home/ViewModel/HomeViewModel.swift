//
//  HomeViewModel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import Foundation

struct IntakeItem: Identifiable {
    let id = UUID()
    let name: String
    let time: Date
    var isCompleted: Bool
}

final class HomeViewModel: ObservableObject {
    @Published var items: [IntakeItem] = []
    @Published var progress: Double = 0

    init(items: [IntakeItem] = []) {
        if items.isEmpty {
            self.items = [
                IntakeItem(name: "오메가", time: Calendar.current.date(bySettingHour: 12, minute: 30, second: 0, of: Date())!, isCompleted: false),
                IntakeItem(name: "유산균", time: Calendar.current.date(bySettingHour: 2, minute: 30, second: 0, of: Date())!, isCompleted: true),
                IntakeItem(name: "비타민D", time: Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!, isCompleted: true),
                IntakeItem(name: "혈당억제제", time: Calendar.current.date(bySettingHour: 20, minute: 30, second: 0, of: Date())!, isCompleted: true),
                IntakeItem(name: "비타민C", time: Calendar.current.date(bySettingHour: 15, minute: 0, second: 0, of: Date())!, isCompleted: true)
            ]
        } else {
            self.items = items
        }
        calculateProgress()
    }

    func toggleCompleted(at index: Int) {
        items[index].isCompleted.toggle()
        calculateProgress()
    }

    private func calculateProgress() {
        guard !items.isEmpty else {
            progress = 0
            return
        }
        let done = items.filter { $0.isCompleted }.count
        progress = Double(done) / Double(items.count)
    }
}
