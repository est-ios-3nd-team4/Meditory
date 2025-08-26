//
//  SheetDayCell.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

struct SheetDayCell: View {
  let date: Date
  let isSelected: Bool
  let isToday: Bool
  let isCurrentMonth: Bool
  let progress: Double
  let onTap: () -> Void

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  private var isPadStyle: Bool { hSize == .regular }

  private var dateFontSize: CGFloat { isPadStyle ? 18 : 16 }
  private var underlineHeight: CGFloat { isPadStyle ? 8 : 6}
  private var baseSize: CGFloat{ isPadStyle ? 36 : 34 }
  private var selectedSize: CGFloat { isPadStyle ? 38 : 36 }
  private var ringLine: CGFloat { isPadStyle ? 4 : 3 }

  var body: some View {
    let clamped = max(0, min(1, progress))
    let size = isSelected ? selectedSize : baseSize
    let layoutSize = max(baseSize, selectedSize)

    VStack(spacing: .smallSpacing) {
      ZStack {
        // 선택된 날: sub 컬러로 채움
        if isSelected {
          Circle()
            .fill(.sub)
            .frame(width: size, height: size)

          // 진행 링(선택일은 반전색으로 얇게)
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

          // 완료(=1.0) & 비선택: sub 컬러로 꽉 채움
        } else if clamped >= 1 {
          Circle()
            .fill(.main)
            .frame(width: size, height: size)

          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .fontWeight(.semibold)
            .foregroundStyle(colorScheme == .dark ? .black : .white)

          // 부분 진행(0~1) & 비선택: sub 컬러 링
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

          // 진행 0 & 비선택: 숫자만
        } else {
          Text(date.formattedDate(date, "d"))
            .font(.notoSans(size: dateFontSize))
            .foregroundStyle(.primary)
        }
      }
      .frame(width: layoutSize, height: layoutSize)
      .opacity(isCurrentMonth ? 1.0 : 0.35)

      // 오늘 + 미완료 + 비선택: 언더라인
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
