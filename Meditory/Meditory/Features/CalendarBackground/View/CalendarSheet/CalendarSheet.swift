//
//  SupplementCalendarSheet.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 하단 반 시트용 달력 (공통 컴포넌트)
/// - selectedDate: 바인딩 날짜
/// - completionMap: 날짜별 완료율(0.0~1.0) → 배지(가득찬 원/진행 링) 표시
struct CalendarSheet: View {
  @Binding var selectedDate: Date
  var completionMap: DayCompletionMap = [:]

  private let model = CalendarDateModel()
  @State private var monthOffset: Int = 0
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

  private var monthBase: Date {
    Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
  }

  var body: some View {
    VStack(spacing: .defaultSpacing) {
      CalendarMonthHeader(
        title: monthBase.yearMonth,
        onPrev: { monthOffset -= 1 },
        onNext: { monthOffset += 1 },
        onToday: {
          withAnimation {
            monthOffset = 0
            selectedDate = Calendar.current.startOfDay(for: Date())
          }
        }
      )

      CalendarWeekdayHeader()

      LazyVGrid(columns: columns, spacing: .defaultSpacing) {
        ForEach(model.daysInMonthGrid(monthBase), id: \.timeIntervalSince1970) { date in
          let isSel = model.isSameDay(date, selectedDate)
          let isTod = model.isToday(date)
          let inMonth = model.isSameMonth(date, baseMonth: monthBase)
          let progress = completionMap.progress(for: date, calendar: model.calendar)

          SheetDayCell(
            date: date,
            isSelected: isSel,
            isToday: isTod,
            isCurrentMonth: inMonth,
            progress: progress
          ) {
            selectedDate = date
          }
        }
      }
      .padding(.horizontal)

      Spacer(minLength: 0)
    }
    .padding(.top, .defaultSpacing + 8)
  }
}
#Preview {
  struct PreviewWrapper: View {
    @State private var selectedDate = Date()

    private let demoCompletion: DayCompletionMap = {
      let cal = Calendar.current
      func d(_ y:Int,_ m:Int,_ dd:Int) -> Date {
        cal.startOfDay(for: DateComponents(calendar: cal, year: y, month: m, day: dd).date!)
      }
      return [
        d(2025,8,5):  0.33,
        d(2025,8,13): 1.0,
        d(2025,8,18): 0.66,
        d(2025,8,29): 0.0
      ]
    }()

    var body: some View {
      CalendarSheet(
        selectedDate: $selectedDate,
        completionMap: demoCompletion
      )
    }
  }
  return PreviewWrapper()
}

