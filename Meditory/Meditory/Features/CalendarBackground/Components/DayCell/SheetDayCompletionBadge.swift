//
//  SheetDayCompletionBadge.swift
//  Meditory
//
//  Created by 윤혜주 on 8/18/25.
//

import SwiftUI

enum CompletedBadgeStyle { case filled, ringBorder }

struct SheetDayCompletionBadge: View {
  let progress: Double
  var size: CGFloat = 30
  var lineWidth: CGFloat = 3
  var completedStyle: CompletedBadgeStyle = .filled

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    let clamped = max(0, min(1, progress))

    ZStack {
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

      } else {
        Circle()
          .fill(Color.clear)
          .frame(width: size, height: size)
      }
    }
    .frame(width: size, height: size)
  }
}

