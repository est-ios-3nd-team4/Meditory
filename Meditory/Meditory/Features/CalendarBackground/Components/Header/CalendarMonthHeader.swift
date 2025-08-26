//
//  CalendarMonthHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/15/25.
//

import SwiftUI

/// 월 이동 헤더 
struct CalendarMonthHeader: View {
  let title: String
  var onPrev: () -> Void
  var onNext: () -> Void
  var onToday: () -> Void
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  private var isPadStyle: Bool { hSize == .regular }

  private var iconFontSize: CGFloat { isPadStyle ? 20 : 18 }
  private var titleFontSize: CGFloat { isPadStyle ? 22 : 20 }
  private var todayFontSize: CGFloat { isPadStyle ? 15 : 13 }
  var body: some View {
    ZStack {
      HStack(spacing: .defaultSpacing) {
        Button(action: onPrev) {
          Image(systemName: "chevron.left")
            .font(.notoSans(size: iconFontSize))
            .foregroundStyle(Color.primary.opacity(0.5))
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
        }

        Text(title)
          .font(.notoSans(size: titleFontSize))
          .foregroundStyle(.primary)
          .fontWeight(.bold)
          .lineLimit(1)
          .minimumScaleFactor(0.9)

        Button(action: onNext) {
          Image(systemName: "chevron.right")
            .font(.notoSans(size: iconFontSize))
            .foregroundStyle(Color.primary.opacity(0.5))
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
        }
      }

      HStack {
        Spacer()
        Button(action: onToday) {
          Text("오늘")
            .foregroundStyle(.secondary)
            .font(.notoSans(size: todayFontSize))
            .fontWeight(.semibold)
            .padding(.horizontal, .defaultSpacing)
            .padding(.vertical, .smallSpacing/2)
            .background(Color.secondary.opacity(0.1), in: Capsule())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal)
  }
}

#Preview {
  struct CalendarMonthHeaderPreview: View {
    @State private var month: Date = Date()
    private let cal = Calendar.current
    private let model = CalendarDateModel()

    var body: some View {
      VStack(spacing: .defaultSpacing) {
        CalendarMonthHeader(
          title: month.yearMonth,
          onPrev: {
            if let new = cal.date(byAdding: .month, value: -1, to: month) {
              month = new
            }
          },
          onNext: {
            if let new = cal.date(byAdding: .month, value: 1, to: month) {
              month = new
            }
          },
          onToday: {
            month = cal.startOfDay(for: Date())
          }
        )
        .padding(.vertical, .defaultSpacing)

        Text("현재: \(month.yearMonth)")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
      .padding()
    }
  }

  return CalendarMonthHeaderPreview()
}
