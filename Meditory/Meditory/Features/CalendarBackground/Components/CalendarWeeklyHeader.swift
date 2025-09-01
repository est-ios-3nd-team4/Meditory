//
//  CalendarWeeklyHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

/// 주간 헤더 상·하 좌우 여백 규격 모음입니다.
/// - iPad 가로/세로, iPhone 환경에 따라 수평 인셋을 다르게 적용합니다.
enum HorizontalInset {
  // iPad 가로 모드
  enum Landscape {
    static let ipad13: CGFloat = 100
    static let ipad11: CGFloat = 80
  }
  
  // iPad 세로 모드
  enum Portrait {
    static let ipad13: CGFloat = 40
    static let ipad11: CGFloat = 32
  }
  
  // iPhone
  static let iphone: CGFloat = .defaultSpacing
}

/// 주간 캘린더 헤더 뷰입니다.
/// - 구성:
///   1) 상단 월(예: "2025년 8월") 라벨과 드롭 화살표 버튼
///   2) 요일 라인(일~토)
///   3) 날짜 숫자 라인(선택/오늘 상태 반영)
/// - 상호작용:
///   - 월 라벨 탭 시 `onTapMonth` 호출(월 선택 시트/화면 전환 등 외부에 위임)
///   - 요일/날짜 탭 시 `selectedDate`를 해당 날짜로 업데이트
/// - 애니메이션:
///   - 선택된 요일 배경 원은 `matchedGeometryEffect`로 부드럽게 전환됩니다.
/// - 레이아웃:
///   - 기기/방향에 따라 `horizontalInset`을 계산하여 좌우 여백을 동적으로 적용합니다.
///   - 헤더의 하단 Y 좌표를 `headerBottomY`로 외부에 전달하여, 다른 레이아웃(오버랩 처리 등)에서 활용할 수 있습니다.
struct CalendarWeeklyHeader: View {
  // MARK: - External State
  /// 현재 선택된 날짜
  @Binding var selectedDate: Date
  /// 헤더 하단 Y 좌표 (글로벌 기준). 외부에서 오버랩/스크롤 효과 등에 사용합니다.
  @Binding var headerBottomY: CGFloat
  /// 날짜 계산/판별 유틸 모델
  let model: CalendarDateModel
  /// 선택 배경 원 애니메이션을 위한 네임스페이스
  let namespace: Namespace.ID
  /// 상단 헤더가 겹쳐 입력을 막아야 하는 상태인지 여부
  var isOverlappingHeader: Bool
  /// 월 라벨 탭 시 호출되는 액션 (월 변경 시트/화면 노출 등)
  var onTapMonth: () -> Void
  
  // MARK: - Environment
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize
  
  // MARK: - Layout Flags
  /// iPad 스타일 여부
  private var isPadStyle: Bool { hSize == .regular }
  
  /// iPad 가로 방향 여부 (기기/화면 비율 기반)
  private var isLandscape: Bool {
    UIDevice.isPad &&
    UIScreen.main.bounds.width > UIScreen.main.bounds.height
  }
  
  // MARK: - Typography & Metrics
  /// 상단 “YYYY년 M월” 텍스트 크기
  private var yearMonthFontSize: CGFloat { .defaultFontSize + 2 }
  /// 드롭 화살표 아이콘 크기
  private var chevronFontSize: CGFloat { .defaultFontSize - 3 }
  /// 요일(일~토) 텍스트 크기
  private var weekNameFontSize: CGFloat { .defaultFontSize - 5 }
  /// 날짜 숫자 텍스트 크기
  private var dateFontSize: CGFloat { .defaultFontSize - 2 }
  /// 선택/오늘 배경 원 크기 (기기별)
  private var circleSize: CGSize {
    let isPad = UIDevice.isPad
    return CGSize(width: isPad ? 35 : 25, height: isPad ? 35 : 25)
  }
  
  /// 화면/기기/방향에 따른 수평 인셋 계산값
  private var horizontalInset: CGFloat {
    let screenWidth = UIScreen.main.bounds.width
    
    if isLandscape {
      // iPad 가로 모드
      return screenWidth > 1200
      ? HorizontalInset.Landscape.ipad13
      : HorizontalInset.Landscape.ipad11
    } else if isPadStyle {
      // iPad 세로 모드
      return screenWidth > 1200
      ? HorizontalInset.Portrait.ipad13
      : HorizontalInset.Portrait.ipad11
    } else {
      // iPhone
      return HorizontalInset.iphone
    }
  }
  
  // MARK: - Constants
  /// 주 7일 그리드
  private let columns = Array(repeating: GridItem(.flexible()), count: 7)
  /// 요일 표기(일~토)
  private let weekNames = ["일","월","화","수","목","금","토"]
  
  // MARK: - Helpers
  /// 현재 `selectedDate`가 속한 주(일~토)의 Date 배열을 반환합니다.
  private func weekDays() -> [Date] {
    let cal = model.calendar
    let weekday = cal.component(.weekday, from: selectedDate) // 1(일)~7(토)
    let startOfWeek = cal.date(byAdding: .day, value: -(weekday - 1), to: selectedDate)!
    return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: startOfWeek) }
  }
  
  // MARK: - View
  var body: some View {
    let dates = weekDays()
    
    return VStack(alignment: .leading, spacing: 0) {
      // MARK: - 상단 월 라벨 영역
      Button(action: onTapMonth) {
        HStack(spacing: .smallSpacing) {
          Text(selectedDate.yearMonth)
            .foregroundStyle(.white)
            .font(.notoSans(size: yearMonthFontSize))
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.9)
          
          Image(systemName: "chevron.down")
            .font(.notoSans(size: chevronFontSize))
            .fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.vertical, .smallSpacing)
      }
      .buttonStyle(.plain)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, horizontalInset)
      
      // MARK: - 요일(일~토) 라인
      LazyVGrid(columns: columns, spacing: 0) {
        ForEach(dates.indices, id: \.self) { i in
          let date = dates[i]
          let selected = model.isSameDay(date, selectedDate)
          let today = model.isToday(date)
          
          ZStack {
            if selected {
              // 선택된 요일 배경(흰색 원) - matchedGeometry로 부드럽게 이동
              Circle()
                .fill(.white)
                .frame(width: circleSize.width, height: circleSize.height)
                .matchedGeometryEffect(id: "backgroundCircle", in: namespace)
            } else if today {
              // 오늘(비선택) 표식 - 흐린 흰색 원
              Circle()
                .fill(.white)
                .frame(width: circleSize.width, height: circleSize.height)
                .opacity(0.3)
            }
            
            Text(weekNames[i])
              .font(.notoSans(size: weekNameFontSize))
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
      
      // MARK: - 날짜 숫자 라인
      LazyVGrid(columns: columns, spacing: 0) {
        ForEach(dates, id: \.self) { date in
          VStack {
            Text(date.formattedDate(date, "d"))
              .font(.notoSans(size: dateFontSize))
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
          }
          .frame(minHeight: 40, alignment: .top)
          .contentShape(Rectangle())
          .onTapGesture {
            guard !isOverlappingHeader else { return }
            withAnimation { selectedDate = date }
          }
        }
      }
    }
    .padding(.horizontal, .defaultSpacing)
    // MARK: - 헤더 하단 Y 좌표 전달용 지오메트리
    .background(
      GeometryReader { proxy in
        let bottom = proxy.frame(in: .global).maxY
        Color.clear
          .onAppear { headerBottomY = bottom }
          .onChange(of: bottom) { _, new in headerBottomY = new }
      }
    )
    // 헤더가 겹칠 경우 입력 차단
    .allowsHitTesting(!isOverlappingHeader)
    // 상단 영역 배경색
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
