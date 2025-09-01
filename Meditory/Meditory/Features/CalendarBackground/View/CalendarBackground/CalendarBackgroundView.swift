//
//  CalendarBackgroundView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//

import SwiftUI

/// 홈 화면에서 사용되는 달력 기반 배경 뷰입니다.
/// - 구성:
///   1) 상단: 주간 헤더(`CalendarWeeklyHeader`)
///   2) 하단: 선택된 날짜에 대응하는 콘텐츠 영역
/// - 기능:
///   - 월 라벨 탭 → 하단 1/2 시트(`SupplementCalendarSheet`) 열림
///   - 좌/우 스와이프 → 주(week) 단위 이동
///   - 스크롤과 헤더의 Y 좌표 변화를 추적하여, 콘텐츠 레이아웃 오버랩 상태 관리
/// - 제네릭:
///   - `Content` 제네릭으로, 날짜별로 표시할 실제 콘텐츠 뷰를 외부에서 주입합니다.
struct CalendarBackgroundView<Content: View>: View {
  /// 외부에서 바인딩되는 현재 선택된 날짜
  @Binding var selectedDate: Date
  /// 날짜별 완료율 맵 (달력 하이라이트에 사용)
  var completionMap: DayCompletionMap = [:]
  
  @Environment(\.colorScheme) private var colorScheme
  @Namespace private var namespace
  
  /// 내부 UI 상태를 관리하는 뷰모델
  @StateObject private var vm = CalendarBackgroundViewModel()
  
  /// 달력 계산 유틸
  private let model = CalendarDateModel()
  /// 날짜에 따른 콘텐츠 빌더
  private let content: (Date) -> Content
  
  /// CalendarBackgroundView 초기화 메서드
  /// - Parameters:
  ///   - selectedDate: 외부에서 바인딩되는 현재 선택 날짜
  ///   - completionMap: 날짜별 완료율 맵 (기본값: `[:]`)
  ///   - content: 선택된 날짜에 맞춰 표시할 콘텐츠 빌더
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
        // MARK: - 상단 주간 헤더
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
        
        // MARK: - 하단 콘텐츠 영역
        GeometryReader { innerGeo in
          ZStack {
            // 배경 레이어 (상단 main, 하단 customBackground)
            VStack(spacing: 0) {
              Color.main
              Color.customBackground.frame(maxHeight: .infinity)
            }
            .ignoresSafeArea()
            
            // 콘텐츠 스크롤
            ScrollView(.vertical, showsIndicators: false) {
              ZStack(alignment: .top) {
                Color.clear
                  .frame(minHeight: innerGeo.size.height)
                
                VStack(spacing: .defaultSpacing) {
                  // 첫 번째 카드의 Y 좌표 추적
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
                  
                  // 상단 모서리 라운딩된 카드 형태 콘텐츠
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
    // MARK: - 월 선택 시트
    .sheet(isPresented: $vm.isMonthSheetPresented) {
      CalendarSheet(
        selectedDate: $selectedDate,
        completionMap: completionMap
      )
      .presentationDetents([.fraction(0.7), .large])
      .presentationDragIndicator(.visible)
      .presentationCornerRadius(.defaultRadius)
    }
  }
}


/// 미리보기용 Wrapper
/// - 더미 완료율 데이터를 주입하여 달력 하이라이트 시연
/// - 선택된 날짜를 바인딩하여 실시간 반영
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
