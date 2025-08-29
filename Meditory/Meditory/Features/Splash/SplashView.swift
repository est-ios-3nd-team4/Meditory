//
//  SplashView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/28/25.
//


import SwiftUI

struct SplashView: View {
  let imageName: String
  /// 표시 시간(초)
  let showDuration: Double
  /// 종료 콜백
  let onFinish: () -> Void
  @State private var scale: CGFloat = 0.98
  let iconWidth: CGFloat = UIDevice.isPad ? 200 : 100

  init(imageName: String = "icon_meditory",
       showDuration: Double = 1.2,
       onFinish: @escaping () -> Void) {
    self.imageName = imageName
    self.showDuration = showDuration
    self.onFinish = onFinish
  }

  var body: some View {
    Color.main
      .ignoresSafeArea()
      .overlay {
        Image(imageName)
          .resizable()
          .scaledToFit()
          .frame(width: iconWidth)
      }
      .onAppear {
        withAnimation(.easeInOut(duration: 0.25)) {
          scale = 1
        }
        // 일정 시간 뒤 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + showDuration) {
          onFinish()
        }
      }
  }
}
