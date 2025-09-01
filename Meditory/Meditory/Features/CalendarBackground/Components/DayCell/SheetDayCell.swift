//
//  SheetDayCell.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

/// 달력 시트(Calendar Sheet)에서 **하루 단위 셀**을 표현하는 뷰입니다.
/// - 역할:
///   - 날짜 숫자와 복용 달성률(progress)을 시각적으로 표시합니다.
///   - 선택 여부, 오늘 여부, 현재 월 포함 여부에 따라 스타일이 달라집니다.
/// - 상태별 UI 규칙:
///   1. 선택됨 → 원형 배경을 `sub` 컬러로 채우고, 진행률이 있으면 흰색 링으로 표시.
///   2. 완료(=1.0) & 비선택 → 원형 배경을 `main` 컬러로 채움.
///   3. 부분 진행(0~1) & 비선택  → `main` 컬러 링을 표시.
///   4. 진행 0 & 비선택 → 날짜 텍스트만 표시.
///   5. 오늘 + 미완료 + 비선택 → 날짜 아래에 얇은 언더라인 표시.
///   6. 현재 달 아님 → 전체 투명도를 낮춰(0.35) 비활성화 느낌을 줌.
/// - 상호작용:
///   - 셀을 탭하면 `onTap` 클로저가 실행됩니다.
struct SheetDayCell: View {
  /// 표시할 날짜
  let date: Date
  /// 선택 상태 여부
  let isSelected: Bool
  /// 오늘 날짜 여부
  let isToday: Bool
  /// 현재 월 소속 여부
  let isCurrentMonth: Bool
  /// 달성률 (0.0~1.0, 범위 초과 값은 0~1로 클램핑)
  let progress: Double
  /// 셀 탭 시 실행할 액션
  let onTap: () -> Void
  
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize
  
  /// iPad 스타일 여부
  private var isPadStyle: Bool { hSize == .regular }
  
  /// 날짜 텍스트 폰트 크기
  private var dateFontSize: CGFloat { isPadStyle ? 18 : 16 }
  /// 오늘 언더라인 높이
  private var underlineHeight: CGFloat { isPadStyle ? 8 : 6 }
  /// 기본 원 크기
  private var baseSize: CGFloat { isPadStyle ? 36 : 34 }
  /// 선택된 원 크기
  private var selectedSize: CGFloat { isPadStyle ? 38 : 36 }
  /// 진행률 링 두께
  private var ringLine: CGFloat { isPadStyle ? 4 : 3 }
  
  var body: some View {
    // progress는 0~1 범위로 고정
    let clamped = max(0, min(1, progress))
    let size = isSelected ? selectedSize : baseSize
    let layoutSize = max(baseSize, selectedSize)
    
    VStack(spacing: .smallSpacing) {
      ZStack {
        // MARK: - 선택 상태
        if isSelected {
          Circle()
            .fill(.sub)
            .frame(width: size, height: size)
          
          // 진행 중 (0 < progress < 1) → 흰색 링
          if clamped > 0 && clamped < 1 {
            Circle()
              .inset(by: ringLine / 2)
              .trim(from: 0, to: clamped)
              .stroke(style: StrokeStyle(lineWidth: ringLine, lineCap: .round))
              .rotationEffect(.degrees(-90))
              .frame(width: size, height: size)
              .foregroundStyle(.white.opacity(0.8))
          }
          
          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .fontWeight(.semibold)
            .foregroundStyle(.white)
          
          // MARK: - 완료(=1.0) & 비선택
        } else if clamped >= 1 {
          Circle()
            .fill(.main)
            .frame(width: size, height: size)
          
          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .fontWeight(.semibold)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
          
          // MARK: - 부분 진행(0~1) & 비선택
        } else if clamped > 0 {
          Circle()
            .inset(by: ringLine / 2)
            .stroke(Color.primary.opacity(0.12), lineWidth: ringLine)
            .frame(width: size, height: size)
          
          Circle()
            .inset(by: ringLine / 2)
            .trim(from: 0, to: clamped)
            .stroke(style: StrokeStyle(lineWidth: ringLine, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: size, height: size)
            .foregroundStyle(.main)
          
          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .foregroundStyle(.primary)
          
          // MARK: - 진행 0 & 비선택
        } else {
          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .foregroundStyle(.primary)
        }
      }
      .frame(width: layoutSize, height: layoutSize)
      .opacity(isCurrentMonth ? 1.0 : 0.35)
      
      // MARK: - 오늘 + 미완료 + 비선택 → 언더라인
      ZStack {
        if isToday && clamped == 0 && !isSelected {
          Capsule()
            .fill(Color.secondary.opacity(0.55))
            .frame(width: 18, height: 2)
        } else {
          Color.clear
            .frame(width: 18, height: 2)
        }
      }
      .frame(height: underlineHeight)
    }
    .frame(minHeight: 40)
    .contentShape(Rectangle())
    .onTapGesture(perform: onTap)
  }
}

#Preview {
  VStack(spacing: .defaultSpacing) {
    HStack(spacing: .defaultSpacing) {
      // 선택된 날짜
      SheetDayCell(
        date: Date(),
        isSelected: true,
        isToday: false,
        isCurrentMonth: true,
        progress: 0.5,
        onTap: {}
      )
      
      // 오늘(미완료)
      SheetDayCell(
        date: Date(),
        isSelected: false,
        isToday: true,
        isCurrentMonth: true,
        progress: 0.0,
        onTap: {}
      )
      
      // 완료일 (progress = 1.0)
      SheetDayCell(
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        isSelected: false,
        isToday: false,
        isCurrentMonth: true,
        progress: 1.0,
        onTap: {}
      )
      
      // 부분 완료 (progress = 0.5)
      SheetDayCell(
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        isSelected: false,
        isToday: false,
        isCurrentMonth: true,
        progress: 0.5,
        onTap: {}
      )
      
      // 다른 달 (isCurrentMonth = false)
      SheetDayCell(
        date: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
        isSelected: false,
        isToday: false,
        isCurrentMonth: false,
        progress: 0.0,
        onTap: {}
      )
    }
  }
  .padding()
}
