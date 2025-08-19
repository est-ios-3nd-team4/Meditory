//
//  CalendarBackgroundView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import SwiftUI

/// 화면 상단 주간 헤더 + 하단 콘텐츠 영역을 가진 배경 뷰
/// - 월 라벨 탭: 하단 1/2 시트(SupplementCalendarSheet)
/// - 좌/우 스와이프: 주(week) 단위 이동
struct CalendarBackgroundView<Content: View>: View {
  @Binding var selectedDate: Date
  var completionMap: DayCompletionMap = [:]
  
  @Environment(\.colorScheme) private var colorScheme
  @Namespace private var namespace
  
  @StateObject private var vm = CalendarBackgroundViewModel()
  
  private let model = CalendarDateModel()
  private let content: (Date) -> Content
  
  init(
    selectedDate: Binding<Date>,
    completionMap: DayCompletionMap = [:],
    @ViewBuilder content: @escaping (Date) -> Content
  ) {
    self._selectedDate = selectedDate
    self.completionMap = completionMap
    self.content = content
  }
  
  var body: some View {
    GeometryReader { geo in
      VStack(spacing: 0) {
        CalendarWeeklyHeader(
          selectedDate: $selectedDate,
          headerBottomY: $vm.headerBottomY,
          model: model,
          namespace: namespace,
          isOverlappingHeader: vm.isOverlappingHeader,
          onTapMonth: { vm.isMonthSheetPresented = true }
        )
        .onChange(of: vm.headerBottomY) { _, newY in
          vm.onHeaderBottomYChanged(newY)
        }
        
        GeometryReader { innerGeo in
          ZStack {
            VStack(spacing: 0) {
              Color.main
              Color.customBackground.frame(maxHeight: .infinity)
            }
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
              ZStack(alignment: .top) {
                Color.clear
                  .frame(minHeight: innerGeo.size.height)
                
                VStack(spacing: .defaultSpacing) {
                  Color.clear
                    .frame(height: 1)
                    .background(
                      GeometryReader { proxy in
                        let cardTop = proxy.frame(in: .global).minY
                        Color.clear
                          .onAppear { vm.onFirstCardTopChanged(cardTop) }
                          .onChange(of: cardTop) { _, newY in vm.onFirstCardTopChanged(newY) }
                      }
                    )
                  
                  ZStack {
                    Color.customBackground
                    content(selectedDate)
                  }
                  .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .topRight]))
                }
                .padding(.bottom, .defaultSpacing)
              }
            }
            .background(Color.clear)
            .scrollClipDisabled(true)
          }
        }
      }
    }
    .sheet(isPresented: $vm.isMonthSheetPresented) {
      CalendarSheet(
        selectedDate: $selectedDate,
        completionMap: completionMap
      )
      .presentationDetents([.fraction(0.6)])
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(24)
    }
  }
}


private struct CalendarBackgroundPreviewWrapper: View {
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
    CalendarBackgroundView(
      selectedDate: $selectedDate,
      completionMap: demoCompletion
    ) { _ in
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
                Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                  .font(.notoSans(size: 12))
                  .foregroundStyle(.secondary)
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
}

#Preview {
  CalendarBackgroundPreviewWrapper()
}
