//
//  CircularProgressView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var lineWidth: CGFloat = 20

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width/2, y: geo.size.height/2)

            let strokeRadius = side / 2
            let angle = Angle(degrees: progress * 360 - 90)
            let radians = CGFloat(angle.radians)

            let knobCenter = CGPoint(
                x: center.x + cos(radians) * strokeRadius,
                y: center.y + sin(radians) * strokeRadius
            )

            ZStack {
                // 그래프 배경 회색
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)

                // 그래프
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [Color.sub, Color.main]),
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))


                // 그래프 위 원
                Circle()
                    .fill(Color.white)
                    .frame(width: lineWidth, height: lineWidth)
                    .overlay(
                        Circle()
                            .fill(Color.main)
                            .frame(width: lineWidth * 0.5,
                                   height: lineWidth * 0.5)
                    )
                    .position(knobCenter)
                    .zIndex(2)

                // 퍼센트
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 60, weight: .bold))
                    Text("%")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundColor(.black)
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
