//
//  SupplementCalendarSheet.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 하단 반 시트에서 표시되는 월간 달력 컴포넌트입니다.
/// - 특징:
///   - `selectedDate`: 외부와 바인딩된 현재 선택된 날짜
///   - `completionMap`: 날짜별 완료율(0.0~1.0)을 기반으로 셀에 완료 뱃지 표시
///   - 월 단위 이동(이전/다음) 및 "오늘" 버튼 제공
///   - 달력은 월요일 시작 기준으로 정렬됩니다.
/// - UI 구성:
///   1) `CalendarMonthHeader` → 월 이동 및 오늘 버튼
///   2) `CalendarWeekdayHeader` → 요일(월~일) 라벨
///   3) `LazyVGrid` → 한 달 날짜 그리드 (`SheetDayCell` 사용)
/// - 시나리오:
///   - 특정 날짜를 탭하면 `selectedDate`가 갱신됩니다.
///   - 선택된 날짜는 하이라이트되며, 오늘은 별도 표시됩니다.
struct CalendarSheet: View {
  /// 외부에서 바인딩되는 현재 선택 날짜
  @Binding var selectedDate: Date
  /// 날짜별 완료율 맵
  var completionMap: DayCompletionMap = [:]
  
  /// 달력 계산 유틸
  private let model = CalendarDateModel()
  /// 현재 기준 월에서 이동한 월 수 (0=이번달, -1=이전달, +1=다음달)
  @State private var monthOffset: Int = 0
  /// 7열(요일 수)에 맞춘 Grid 레이아웃
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
  
  /// 현재 표시 중인 달의 기준 날짜
  private var monthBase: Date {
    Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
  }
  
  var body: some View {
    VStack(spacing: .defaultSpacing) {
      // MARK: - 상단 월 헤더
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
      
      // MARK: - 요일 라벨
      CalendarWeekdayHeader()
      
      // MARK: - 날짜 그리드
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
