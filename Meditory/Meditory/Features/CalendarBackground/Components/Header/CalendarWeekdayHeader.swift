//
//  CalendarWeekdayHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 달력 상단에 표시되는 요일 헤더 뷰입니다.
/// - 역할:
///   - "월 ~ 일" 요일 문자열을 일렬로 표시합니다.
///   - 각 요일은 동일한 폭으로 배치되어 달력 그리드 정렬을 지원합니다.
/// - UI 특징:
///   - 다크/라이트 모드에 따라 `.secondary` 색상을 사용하여 보조 텍스트 스타일을 적용합니다.
///   - iPad 여부(`isPadStyle`)에 따라 폰트 크기를 달리 적용합니다.
struct CalendarWeekdayHeader: View {
  /// 요일 배열 (월~일)
  private let week = ["월","화","수","목","금","토","일"]

  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  /// iPad 스타일 여부
  private var isPadStyle: Bool { hSize == .regular }

  /// 요일 텍스트 폰트 크기
  private var weekFontSize : CGFloat {
    isPadStyle ? .defaultFontSize : .defaultFontSize - 2
  }

  var body: some View {
    HStack {
      ForEach(week, id: \.self) { w in
        Text(w)
          .foregroundStyle(.secondary)
          .font(.notoSans(size: weekFontSize))
          .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, .defaultSpacing)
  }
}

#Preview {
  CalendarWeekdayHeader()
}
