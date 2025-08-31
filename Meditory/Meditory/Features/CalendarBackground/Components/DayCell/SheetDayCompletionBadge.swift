//
//  SheetDayCompletionBadge.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

/// 완료 뱃지 스타일
/// - `filled`: 전체를 채운 원.
/// - `ringBorder`: 외곽선(링)만 표시.
enum CompletedBadgeStyle { case filled, ringBorder }

/// 달력 셀 옆 등에 표시되는 하루 완료도 뱃지 뷰입니다.
/// - 역할:
///   - 하루 달성률(`progress`)을 0.0 ~ 1.0 범위로 받아 시각화합니다.
///   - 달성률이 1.0 이상이면 완료 뱃지로,
///     0 < progress < 1.0이면 부분 링(progress ring)으로,
///     0.0이면 빈 원으로 표시됩니다.
/// - 디자인:
///   - `completedStyle`에 따라 100% 완료 시 표현 방식을 `filled` / `ringBorder`로 구분할 수 있습니다.
///   - `size`, `lineWidth`를 통해 크기와 링 두께를 조절할 수 있습니다.
///   - 다크 모드일 경우 `filled` 스타일의 색상은 흰색으로, 라이트 모드에서는 `main` 컬러로 표시됩니다.
struct SheetDayCompletionBadge: View {
  /// 달성률 (0.0 ~ 1.0). 범위를 벗어나면 0~1 사이로 클램핑됩니다.
  let progress: Double
  /// 뱃지의 지름 크기 (기본값 30)
  var size: CGFloat = 30
  /// 링 두께 (기본값 3)
  var lineWidth: CGFloat = 3
  /// 완료(=1.0)일 때의 스타일 (채움/외곽선)
  var completedStyle: CompletedBadgeStyle = .filled
  
  @Environment(\.colorScheme) private var colorScheme
  
  var body: some View {
    let clamped = max(0, min(1, progress))
    
    ZStack {
      // MARK: - 100% 완료
      if clamped >= 1 {
        switch completedStyle {
        case .filled:
          Circle()
            .fill(colorScheme == .dark ? Color.white : Color.main)
            .frame(width: size, height: size)
          
        case .ringBorder:
          Circle()
            .inset(by: lineWidth / 2)
            .stroke(Color.main, lineWidth: lineWidth)
            .frame(width: size, height: size)
        }
        
        // MARK: - 부분 진행(0~1)
      } else if clamped > 0 {
        Circle()
          .inset(by: lineWidth / 2)
          .stroke(Color.primary.opacity(0.15), lineWidth: lineWidth)
          .frame(width: size, height: size)
        
        Circle()
          .inset(by: lineWidth / 2)
          .trim(from: 0, to: clamped)
          .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
          .rotationEffect(Angle(degrees: -90))
          .frame(width: size, height: size)
        
        // MARK: - 미완료 (0%)
      } else {
        Circle()
          .fill(Color.clear)
          .frame(width: size, height: size)
      }
    }
    .frame(width: size, height: size)
  }
}
