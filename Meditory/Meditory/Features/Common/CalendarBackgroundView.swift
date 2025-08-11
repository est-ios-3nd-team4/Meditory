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

  private var headerView: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(selectedDate.yearMonth)
        .foregroundStyle(.white)
        .font(.notoSans(size: 20)).fontWeight(.bold)
        .padding(8).padding(.horizontal)

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
            .background { if selected { Circle().fill(.white).frame(width: 25, height: 25) } }
            .onTapGesture { withAnimation { selectedDate = date } }
        }
      }
      .padding(.horizontal)

      LazyVGrid(columns: columns, spacing: 0) {
        ForEach(dates, id: \.self) { date in
          VStack {
            Text(date.formattedDate(date, "d"))
              .font(.notoSans(size: 16))
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
          }
          .frame(minHeight: 40, alignment: .top)
          .onTapGesture { withAnimation { selectedDate = date } }
        }
      }
      .padding(.horizontal)
    }
  }

  var body: some View {
    GeometryReader { geo in
      let safeTop = geo.safeAreaInsets.top

      ZStack(alignment: .top) {
        Color.customBackground.ignoresSafeArea()

        Color.main
          .frame(height: safeTop)
          .ignoresSafeArea(edges: .top)

        ScrollView(showsIndicators: false) {
          VStack(spacing: 0) {
            headerView
              .background(Color.main, ignoresSafeAreaEdges: .top)

            ZStack {
              Color.customBackground
              content(selectedDate)
            }
            .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
            .background(Color.main)
          }
        }
        .background {
          GeometryReader { proxy in
            ZStack(alignment: .top) {
              Color.customBackground.ignoresSafeArea()

              Color.main
                .frame(height: safeTop + 400) 
                .ignoresSafeArea(edges: .top)
            }
          }
        }
      }
    }
  }

}
#Preview {
  CalendarBackgroundView(selectedDate: .constant(Date())) { _ in
    VStack(spacing: .defaultSpacing) {
      ForEach(0..<20, id: \.self) { i in
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.white.opacity(0.8))
          .frame(height: 50)
          .overlay(
            HStack {
              Text("test \(i + 1)")
                .font(.notoSans(size: 16))
              Spacer()
            }
            .padding(.horizontal)
          )
          .modifier(UnifiedShadow())
      }
    }
    .padding()
  }
  .environment(\.locale, Locale(identifier: "ko_KR"))
}
