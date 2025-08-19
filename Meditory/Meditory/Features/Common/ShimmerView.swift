//
//  ShimmerView.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import SwiftUI

struct ShimmerView: View {
  
  @Environment(\.colorScheme) private var colorScheme
  
  /// GeometryReader width 대비 차지할 비율 (0.0 ~ 1.0)
  /// - 0.0: 없음, 1.0: 전체 너비
  let widthRatio: CGFloat
  
  /// CornerRadius 스타일
  /// - `.capsule`: 높이의 절반으로 radius 적용
  /// - `.fixed(CGFloat)`: 고정된 값으로 radius 지정
  let cornerRadius: CornerStyle
  
  init(
    widthRatio: CGFloat = 1.0,
    cornerRadius: CornerStyle = .capsule
  ) {
    self.widthRatio = min(max(widthRatio, 0), 1)
    self.cornerRadius = cornerRadius
  }
  
  @State private var phase: CGFloat = .zero
  
  var body: some View {
    GeometryReader { geometryReader in
      let width = geometryReader.size.width
      let height = geometryReader.size.height
      let whiteScale = colorScheme == .dark ? 0.25 : 0.92
      let shimmerWidth = width * 0.2
      let shimmerColor: Color = colorScheme == .dark ? .black : .init(red: 204, green: 204, blue: 204)
      let shimmerOpacity = colorScheme == .dark ? 0.2 : 0.7
      
      HStack {
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: cornerRadius(height))
            .fill(Color(white: whiteScale))
            .frame(width: width * widthRatio, height: height)
          
          Capsule()
            .fill(shimmerColor.opacity(shimmerOpacity))
            .blur(radius: 8)
            .frame(width: shimmerWidth)
            .offset(x: phase)
        }
        .mask(
          RoundedRectangle(cornerRadius: cornerRadius(height))
            .frame(width: width * widthRatio, height: height)
        )
        
        Spacer()
      }
      .onAppear {
        startAnimation(width: width, shimmerWidth: shimmerWidth)
      }
    }
  }
}


extension ShimmerView {
  private func cornerRadius(_ height: CGFloat) -> CGFloat {
    switch cornerRadius {
    case .capsule:
      return height / 2
    case .fixed(let radius):
      return radius
    }
  }
  
  private func startAnimation(width: CGFloat, shimmerWidth: CGFloat) {
    phase = -shimmerWidth
    withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
      phase = width
    }
  }
}
