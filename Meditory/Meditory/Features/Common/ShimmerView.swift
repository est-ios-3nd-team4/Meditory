//
//  ShimmerView.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import SwiftUI

struct ShimmerView: View {
  
  @Environment(\.colorScheme) private var colorScheme

  var scale: CGFloat = 1.0
  
  @State private var phase: CGFloat = .zero
  
  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = geometry.size.height
      let whiteScale = colorScheme == .dark ? 0.25 : 0.92
      
      RoundedRectangle(cornerRadius: height / 2)
        .fill(Color(white: whiteScale))
        .frame(width: width * scale)
        .overlay(
          LinearGradient(
            gradient: Gradient(colors: [
              .clear,
              .background.opacity(0.3),
              .clear
            ]),
            startPoint: .leading,
            endPoint: .trailing
          )
          .frame(width: width * 0.3)
          .offset(x: phase)
          .mask(
            RoundedRectangle(cornerRadius: height / 2)
              .frame(width: width * scale, height: height)
          )
        )
        .onAppear {
          phase = -(width * 0.3)
          withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase = width
          }
        }
    }
  }
}
