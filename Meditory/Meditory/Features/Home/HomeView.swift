//
//  HomeView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/1/25.
//

import SwiftUI

struct IntakeItem: Identifiable {
    let id = UUID()
    let name: String
    let time: Date
    let isCompleted: Bool
}
struct HomeView: View {
    var items: [IntakeItem] = [
        IntakeItem(
            name: "오메가",
            time: Calendar.current.date(
                bySettingHour: 12, minute: 30, second: 0, of: Date()
            )!,
            isCompleted: false
        ),
        IntakeItem(
            name: "유산균",
            time: Calendar.current.date(
                bySettingHour: 2, minute: 30, second: 0, of: Date()
            )!,
            isCompleted: true
        ),
        IntakeItem(
            name: "비타민D",
            time: Calendar.current.date(
                bySettingHour: 18, minute: 0, second: 0, of: Date()
            )!,
            isCompleted: true
        )
    ]

    var body: some View {
        CalendarBackgroundView {
            VStack {
                VStack {
                    Text("오늘 복용 달성률")
                        .font(.custom("NotoSansKR-Medium", size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 10)

                    CircularProgressView(progress: progress)
                        .frame(width: 200, height: 200)

                    VStack(alignment: .leading) {
                        ForEach(items) { item in
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.custom("NotoSansKR-Medium", size: 20))
                                    .foregroundStyle(.main)

                                Text(item.name)
                                    .font(.custom("NotoSansKR-Medium", size: 20))

                                Spacer()

                                Text(item.time.timeFormatter)
                                    .font(.custom("NotoSansKR-Medium", size: 15))
                                    .foregroundStyle(.main)
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)

                VStack(alignment: .leading) {
                    Text("오늘의 건강 상식")
                        .font(.custom("NotoSansKR-Medium", size: 18))
                        .padding(.bottom)

                    Text("꾸준한 운동은 스트레스 해소와 전반적인 건강 증진에 매우 효과적이므로, 점진적으로 운동량을 늘려보는 것을 권장합니다.")
                        .font(.custom("NotoSansKR-Medium", size: 18))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            }
            .padding()
        }
    }


    var progress: Double {
        guard !items.isEmpty else { return 0 }
        let done = items.filter { $0.isCompleted }.count
        return Double(done) / Double(items.count)
    }
}

#Preview {
    HomeView()
}
