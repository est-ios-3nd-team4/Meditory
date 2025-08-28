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

  init(imageName: String = "img_LoadingScreen",
       showDuration: Double = 1.2,
       onFinish: @escaping () -> Void) {
    self.imageName = imageName
    self.showDuration = showDuration
    self.onFinish = onFinish
  }

  var body: some View {
    // 전체 화면을 이미지로 채움
    Image(imageName)
      .resizable()
      .scaledToFill()
      .ignoresSafeArea()
      .opacity(scale)
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
