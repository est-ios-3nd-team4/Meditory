//
//  TimeRow.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 복용 시간 행(Row) 뷰
/// - 역할:
///   - 루틴의 특정 복용 시간을 한 줄 형태로 표시합니다.
///   - "시간 아이콘 + 복용 시각 + 알약 수량" 구조로 구성됩니다.
/// - 구성 요소:
///   - `IconBadge`: 시계 아이콘과 포인트 색상 배경
///   - **시간 텍스트**: 오전/오후(AM/PM 등) + 시각(hh:mm)
///   - **복용량**: 알약 아이콘과 함께 `"N정"` 형식으로 표시
/// - 특징:
///   - `timeText`는 "오전 8:00" 같은 문자열을 받아 분리하여 표시
///   - `pointColor`는 메인 강조 색상 (시간 텍스트 및 아이콘 색상에 사용)
///   - `pills`는 복용 알약 수량을 나타내는 문자열
struct TimeRow: View {
  /// 표시할 시간 문자열 (예: "오전 8:00")
  let timeText: String
  /// 포인트 색상 (아이콘 및 시간 강조에 사용)
  let pointColor: Color
  /// 복용량 텍스트 (예: "2정")
  let pills: String
  
  var body: some View {
    HStack(spacing: .smallSpacing) {
      // 좌측 아이콘
      IconBadge(
        systemName: "clock.fill",
        backgroundColor: pointColor.opacity(0.12),
        foregroundColor: pointColor
      )
      
      // 시간 표시 (오전/오후 + 시각 분리)
      let comps = timeText.split(separator: " ").map(String.init)
      let period = comps.first ?? ""
      let hm = comps.dropFirst().joined(separator: " ")
      
      if !period.isEmpty {
        Text(period)
          .font(.notoSans(size: .defaultFontSize - 4))
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)
      }
      
      Text(hm.isEmpty ? timeText : hm)
        .font(.notoSans(size: .defaultFontSize - 3))
        .fontWeight(.bold)
        .foregroundStyle(pointColor)
      
      Spacer(minLength: .defaultSpacing)
      
      // 복용량 배지
      HStack(spacing: .smallSpacing) {
        Image(systemName: "pills.fill")
          .imageScale(.small)
        
        Text(pills)
          .font(.notoSans(size: .defaultFontSize - 5))
      }
      .padding(.horizontal, .smallSpacing)
      .padding(.vertical, .smallSpacing)
      .background(
        Capsule()
          .fill(Color.secondary.opacity(0.12))
      )
    }
    .padding(.vertical, .smallSpacing)
  }
}
