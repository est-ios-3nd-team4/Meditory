//
//  CalendarWeekdayHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//


import SwiftUI

/// 요일 헤더 (월 ~ 일)
struct CalendarWeekdayHeader: View {
  private let week = ["월","화","수","목","금","토","일"]
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  private var isPadStyle: Bool { hSize == .regular }

  private var weekFontSize : CGFloat { isPadStyle ? 18 : 16 }
  
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
