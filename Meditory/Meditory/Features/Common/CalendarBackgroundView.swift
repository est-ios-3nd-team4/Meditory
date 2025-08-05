//
//  CalendarBackgroundView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI

struct CalendarBackgroundView<Content: View>: View {
    @State private var currentDate: Date = Date()

    private let columns: [GridItem] = Array(
        repeating: GridItem(.flexible()),
        count: 7
    )
    private let content: Content

    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    /// 오늘을 기준으로 해당 주(일~토)의 Date 배열을 계산
    private func weekDays() -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        // 주 시작(일요일)으로 이동
        let startOfWeek = calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: currentDate
        )!
        return (0..<7).map {
            calendar.date(byAdding: .day, value: $0, to: startOfWeek)!
        }
    }

    /// 오늘과 같은 날짜인지 비교
    private func isSameDay(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: currentDate)
    }

    var body: some View {
        ZStack {
            Color.main
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading) {
                Text(currentDate.yearMonth)
                    .foregroundStyle(.white)
                    .font(.custom("NotoSansKR-Medium", size: 25))
                    .fontWeight(.bold)
                    .padding()

                let dates = weekDays()
                let weekNames = ["일","월","화","수","목","금","토"]

                LazyVGrid(columns: columns) {
                    ForEach(dates.indices, id: \.self) { i in
                        let date = dates[i]
                        let selected = isSameDay(date)
                        Text(weekNames[i])
                            .font(.custom("NotoSansKR-Medium", size: 13))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(selected ? .main : .white)
                            .padding(.vertical, 6)
                            .background {
                                if selected {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 25, height: 25)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    currentDate = date
                                }
                            }
                    }
                }
                .padding(.horizontal)

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(dates, id: \.self) { date in
                        let selected = isSameDay(date)
                        
                        VStack {
                            Text(Date().formattedDate(date, "d"))
                                .font(.custom("NotoSansKR-Medium", size: 16))
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.white)
                            
                            if selected {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 5, height: 5)
                                    .opacity(selected ? 1 : 0)
                            }
                        }
                        .frame(minHeight: 40, alignment: .top)
                        .padding(.vertical, 6)
                        .onTapGesture {
                            withAnimation {
                                currentDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal)

                ZStack {
                    Rectangle()
                        .fill(Color(red: 249/255, green: 249/255, blue: 249/255))
                        .cornerRadius(20)

                    content
                }
            }
        }
    }
}
