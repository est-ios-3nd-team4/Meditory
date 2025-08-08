//
//  CalendarBackgroundView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI

struct CalendarBackgroundView<Content: View>: View {
  @Binding var selectedDate: Date
  
  private let content: (Date) -> Content
  private let columns: [GridItem] = Array(
    repeating: GridItem(.flexible()),
    count: 7
  )

  init(
     selectedDate: Binding<Date>,
     @ViewBuilder content: @escaping (Date) -> Content
   ) {
     self._selectedDate = selectedDate
     self.content = content
   }

  /// 오늘을 기준으로 해당 주(일~토)의 Date 배열을 계산
  private func weekDays() -> [Date] {
    let calendar = Calendar.current
    let weekday = calendar.component(.weekday, from: selectedDate)
    let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: selectedDate)!
    return (0..<7).map { calendar.date(byAdding: .day, value: $0, to: startOfWeek)! }
  }

  /// 오늘과 같은 날짜인지 비교
  private func isSameDay(_ date: Date) -> Bool {
    Calendar.current.isDate(date, inSameDayAs: selectedDate)
  }

  var body: some View {
    ZStack {
      Color.main
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        Text(selectedDate.yearMonth)
          .foregroundStyle(.white)
          .font(.notoSans(size: 20))
          .fontWeight(.bold)
          .padding(8)
          .padding(.horizontal)

        let dates = weekDays()
        let weekNames = ["일","월","화","수","목","금","토"]

        LazyVGrid(columns: columns, spacing: 0) {
          ForEach(dates.indices, id: \.self) { i in
            let date = dates[i]
            let selected = isSameDay(date)
            Text(weekNames[i])
              .font(.notoSans(size: 13))
              .frame(maxWidth: .infinity)
              .foregroundStyle(selected ? .main : .white)
              .padding(.vertical, 8)
              .background {
                if selected {
                  Circle()
                    .fill(Color.white)
                    .frame(width: 25, height: 25)
                }
              }
              .onTapGesture {
                withAnimation {
                  selectedDate = date
                }
              }
          }
        }
        .padding(.horizontal)

        LazyVGrid(columns: columns, spacing: 0) {
          ForEach(dates, id: \.self) { date in
            VStack {
              Text(Date().formattedDate(date, "d"))
                .font(.notoSans(size: 16))
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
            }
            .frame(minHeight: 40, alignment: .top)
            .onTapGesture {
              withAnimation {
                selectedDate = date
              }
            }
          }
        }
        .padding(.horizontal)

        ZStack {
          Rectangle()
            .fill(.customBackground)
            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
            .edgesIgnoringSafeArea(.all)

          content(selectedDate)
        }
      }
    }
  }
}
#Preview {
  CalendarBackgroundView(selectedDate: .constant(Date())) { _ in EmptyView() }
}

