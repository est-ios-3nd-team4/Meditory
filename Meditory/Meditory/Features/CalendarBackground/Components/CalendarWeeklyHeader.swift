//
//  CalendarWeeklyHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

/// 주간 헤더: 상단 월 라벨 + 요일 라인 + 날짜 숫자 라인
struct CalendarWeeklyHeader: View {
  // 외부 상태
  @Binding var selectedDate: Date
  @Binding var headerBottomY: CGFloat
  let model: CalendarDateModel
  let namespace: Namespace.ID
  var isOverlappingHeader: Bool
  var onTapMonth: () -> Void

  @Environment(\.colorScheme) private var colorScheme

  private let columns = Array(repeating: GridItem(.flexible()), count: 7)
  private let weekNames = ["일","월","화","수","목","금","토"]

  // 선택된 날짜가 속한 주(일~토)
  private func weekDays() -> [Date] {
    let cal = model.calendar
    let weekday = cal.component(.weekday, from: selectedDate) // 1(일)~7(토)
    let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: selectedDate)!
    return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
  }

  var body: some View {
    let dates = weekDays()

    return VStack(alignment: .leading, spacing: 0) {
      Button(action: onTapMonth) {
        HStack(spacing: .smallSpacing) {
          Text(selectedDate.yearMonth)
            .foregroundStyle(.white)
            .font(.notoSans(size: 20)).fontWeight(.bold)
            .padding(.leading, .defaultSpacing)

          Image(systemName: "chevron.down")
            .font(.notoSans(size: 15)).fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.vertical, .smallSpacing)
      }
      .buttonStyle(.plain)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, .defaultSpacing)

      // 요일(일~토)
      LazyVGrid(columns: columns, spacing: 0) {
        ForEach(dates.indices, id: \.self) { i in
          let date = dates[i]
          let selected = model.isSameDay(date, selectedDate)
          let today = model.isToday(date)

          ZStack {
            if selected {
              Circle()
                .fill(.white)
                .frame(width: 25, height: 25)
                .matchedGeometryEffect(id: "backgroundCircle", in: namespace)
            } else if today {
              Circle()
                .fill(.white)
                .frame(width: 25, height: 25)
                .opacity(0.3) // 오늘(비선택) 흐린 원
            }

            Text(weekNames[i])
              .font(.notoSans(size: 13))
              .foregroundStyle(selected ? .main : .white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, .smallSpacing)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            guard !isOverlappingHeader else { return }
            withAnimation { selectedDate = date }
          }
        }
      }
      .padding(.horizontal)

      // 날짜 숫자 라인
      LazyVGrid(columns: columns, spacing: 0) {
        ForEach(dates, id: \.self) { date in
          VStack {
            Text(date.formattedDate(date, "d"))
              .font(.notoSans(size: 16))
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
          }
          .frame(minHeight: 40, alignment: .top)
          .onTapGesture {
            withAnimation { selectedDate = date }
          }
        }
      }
      .padding(.horizontal)
    }
    .background(
      GeometryReader { proxy in
        let bottom = proxy.frame(in: .global).maxY
        Color.clear
          .onAppear { headerBottomY = bottom }
          .onChange(of: bottom) { _, new in headerBottomY = new }
      }
    )
    .allowsHitTesting(!isOverlappingHeader)
    .background(Color.main)
  }
}

private struct CalendarWeeklyHeaderPreview: View {
  @State private var selectedDate: Date = Date()
  @State private var headerBottomY: CGFloat = 0
  @Namespace private var ns

  private let model = CalendarDateModel()

  var body: some View {
    ZStack {
      Color.main.ignoresSafeArea()
      CalendarWeeklyHeader(
        selectedDate: $selectedDate,
        headerBottomY: $headerBottomY,
        model: model,
        namespace: ns,
        isOverlappingHeader: false,
        onTapMonth: { }
      )
    }
    .environment(\.locale, Locale(identifier: "ko_KR"))
  }
}

#Preview("Light") {
  CalendarWeeklyHeaderPreview()
    .preferredColorScheme(.light)
}
