//
//  WeekdayChips.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 요일 칩(Chip) 뷰
/// - 역할:
///   - 루틴의 복용 주기를 요일 단위로 칩 형태로 표시합니다.
///   - 예: `["월", "수", "금"]` → "월" "수" "금" 칩 UI로 표시
/// - 특징:
///   - 각 요일은 캡슐(Capsule) 모양 배경 위에 표시됨
///   - 접근성 라벨(`accessibilityLabel`) 제공 → VoiceOver에서 "월 주기"와 같이 읽힘
///   - `weekdays` 배열을 그대로 반복하여 표시
struct WeekdayChips: View {
  /// 표시할 요일 문자열 배열 (예: ["월", "화", "수"])
  let weekdays: [String]
  
  var body: some View {
    HStack(spacing: .smallSpacing) {
      Spacer(minLength: 0)
      ForEach(weekdays, id: \.self) { text in
        Text(text)
          .font(.notoSans(size: .defaultFontSize - 5))
          .fontWeight(.semibold)
          .padding(.horizontal, .smallSpacing)
          .padding(.vertical, .smallSpacing / 2)
          .background(
            Capsule().fill(Color.secondary.opacity(0.12))
          )
          .foregroundStyle(.secondary)
          .accessibilityLabel("\(text) 주기")
      }
    }
  }
}
