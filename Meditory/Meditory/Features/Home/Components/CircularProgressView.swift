//
//  CircularProgressView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI

struct CircularProgressView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize

  private var isPadStyle: Bool { hSize == .regular }

  private var numberFontSize: CGFloat { isPadStyle ? 80 : 60 }
  private var percentFontSzie: CGFloat { isPadStyle ? 30 : 20 }

  var progress: Double
  var lineWidth: CGFloat { isPadStyle ? 25 : 20 }

  var body: some View {
    GeometryReader { geo in
      let side = min(geo.size.width, geo.size.height)
      let radius = (side - lineWidth) / 2

      ZStack {
        // 그래프 배경 회색
        Circle()
          .inset(by: lineWidth/2)
          .stroke(Color.chartBackground, lineWidth: lineWidth)

        // 그래프
        Circle()
          .inset(by: lineWidth/2)
          .trim(from: 0, to: progress)
          .stroke(
            AngularGradient(
              gradient: Gradient(colors: [Color.sub, Color.main, Color.sub]),
              center: .center
            ),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
          .animation(.easeInOut(duration: 0.6), value: progress)

        // 그래프 위 원
        Circle()
          .fill(Color.white)
          .frame(width: lineWidth, height: lineWidth)
          .overlay(
            Circle()
              .fill(Color.main)
              .frame(width: lineWidth * 0.5, height: lineWidth * 0.5)
          )
          .offset(x: 0, y: -radius)
          .rotationEffect(.degrees(progress * 360))
          .opacity((progress == 0.0 || progress == 1.0) ? 0 : 1)
          .animation(.easeInOut(duration: 0.6), value: progress)

        // 퍼센트
        HStack(alignment: .firstTextBaseline, spacing: 5) {
          Text("\(Int(progress * 100))")
            .font(.notoSans(size: numberFontSize))
          Text("%")
            .font(.notoSans(size: percentFontSzie))
        }
        .foregroundStyle(Color.label)
        .offset(y: -radius * 0.1)
      }
      .frame(width: side, height: side)
    }
    .aspectRatio(1, contentMode: .fit)
  }
}
#Preview {
  MainTabView()
}
