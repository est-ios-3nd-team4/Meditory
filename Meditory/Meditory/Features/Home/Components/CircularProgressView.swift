//
//  CircularProgressView.swift
//  Meditory
//
//  Created by 윤혜주 on 8/4/25.
//
import SwiftUI

/// 원형 진행률(Progress)을 표시하는 커스텀 뷰입니다.
/// - 배경 원, 진행률 원, 진행률 끝 점(작은 원), 퍼센트 텍스트로 구성됩니다.
/// - iPad/Phone 화면 크기에 맞추어 글자 크기와 두께(lineWidth)를 자동 조절합니다.
struct CircularProgressView: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  @Environment(\.verticalSizeClass) private var vSize
  
  /// iPad 스타일 여부 판별 (SizeClass 기반)
  private var isPadStyle: Bool { hSize == .regular }
  
  /// 퍼센트 숫자 글꼴 크기
  private var numberFontSize: CGFloat { isPadStyle ? 80 : 60 }
  /// 퍼센트 기호(%) 글꼴 크기
  private var percentFontSzie: CGFloat { isPadStyle ? 30 : 20 }
  
  /// 진행률 (0.0 ~ 1.0)
  var progress: Double
  /// 원형 선(line) 두께
  var lineWidth: CGFloat { isPadStyle ? 25 : 20 }
  
  var body: some View {
    GeometryReader { geo in
      let side = min(geo.size.width, geo.size.height) // 정사각형 기준 사이즈
      let radius = (side - lineWidth) / 2  // 반지름 계산
      
      ZStack {
        // 그래프 배경 회색
        Circle()
          .inset(by: lineWidth/2)
          .stroke(Color.chartBackground, lineWidth: lineWidth)
        
        // 그래프
        Circle()
          .inset(by: lineWidth/2)
          .trim(from: 0, to: progress) // progress 비율만큼 잘라서 표시
          .stroke(
            AngularGradient(
              gradient: Gradient(colors: [Color.sub, Color.main, Color.sub]),
              center: .center
            ),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
          )
          .rotationEffect(.degrees(-90)) // 시작 각도를 위쪽(12시 방향)으로 조정
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
          .rotationEffect(.degrees(progress * 360))// 진행률에 따른 회전
          .opacity((progress == 0.0 || progress == 1.0) ? 0 : 1) // 0%/100%에서는 숨김
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
