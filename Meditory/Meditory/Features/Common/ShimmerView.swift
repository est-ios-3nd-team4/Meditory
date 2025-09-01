//
//  ShimmerView.swift
//  Meditory
//
//  Created by 홍승아 on 8/18/25.
//

import SwiftUI

/// ShimmerView
/// 데이터 로딩 상태를 사용자에게 알려주기 위한 **스켈레톤 UI(Shimmer 효과)** 컴포넌트입니다.
/// 뷰가 로드되기 전 placeholder 역할을 하며, 좌→우 방향으로 흐르는 그라데이션 애니메이션을 통해
/// 로딩 중임을 시각적으로 표시합니다.
///
/// - 주요 기능:
///   - `widthRatio`: 부모 뷰 너비 대비 차지할 비율을 설정 (0.0 ~ 1.0).
///   - `cornerRadius`: 모서리 스타일 지정 (`.capsule` 또는 `.fixed`).
///   - **밝은 모드/다크 모드 대응**: 환경(`colorScheme`)에 따라 배경/하이라이트 색상과 투명도 자동 조정.
///   - 무한 반복 애니메이션으로 부드러운 로딩 효과 제공.
///
/// - 속성:
///   - `widthRatio`: placeholder 가로 크기 비율 (기본값 1.0).
///   - `cornerRadius`: 모서리 스타일(`CornerStyle`, 기본값 `.capsule`).
///
/// - 내부 동작:
///   - GeometryReader로 가용 공간 측정.
///   - RoundedRectangle 마스크를 적용해 지정된 크기만큼 Shimmer 효과 표시.
///   - `onAppear` 시 `startAnimation` 실행 → 좌측 바깥에서 우측으로 반복 이동.
///
/// - 활용처:
///   - 로딩 중인 텍스트, 카드, 버튼 등 콘텐츠 대신 임시 자리 표시.
///   - 리스트, 상세 뷰 등 데이터 fetch 지연 시 사용자 경험(UX) 개선.
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
      let shimmerWidth = width * 2
      let shimmerColor: Color = colorScheme == .dark ? .black : .init(red: 204, green: 204, blue: 204)
      let shimmerOpacity = colorScheme.isDarkMode ? 0.2 : 0.5
      
      HStack(spacing: .zero) {
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: cornerRadius(height))
            .fill(Color(white: whiteScale))
          
          RoundedRectangle(cornerRadius: cornerRadius(height))
            .fill(shimmerGradient(shimmerColor: shimmerColor, opacity: shimmerOpacity))
            .frame(width: shimmerWidth)
            .blur(radius: 8)
            .offset(x: phase)
        }
        .frame(width: width * widthRatio, height: height, alignment: .leading)
        .mask(
          RoundedRectangle(cornerRadius: cornerRadius(height))
            .frame(width: width * widthRatio, height: height)
        )
        
        if widthRatio < 1 {
          Spacer()
        }
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
    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
      phase = width
    }
  }
  
  private func shimmerGradient(shimmerColor: Color, opacity: Double) -> LinearGradient {
    LinearGradient(
      colors: [
        shimmerColor.opacity(0),
        shimmerColor.opacity(opacity * 0.2),
        shimmerColor.opacity(opacity * 0.6),
        shimmerColor.opacity(opacity),
        shimmerColor.opacity(opacity * 0.6),
        shimmerColor.opacity(opacity * 0.2),
        shimmerColor.opacity(0)
      ],
      startPoint: .leading,
      endPoint: .trailing
    )
  }
}
