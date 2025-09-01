//
//  UnifiedSectionCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

/// 앱 전반에서 재사용하는 **통일된 카드 레이아웃 컨테이너**입니다.
/// - 목적:
///   - 내부 `content`를 일관된 카드 스타일(여백, 라운드, 배경, 외곽선, 그림자)로 감싸서 표시합니다.
/// - 커스터마이즈:
///   - 포인트 색상(`pointColor`), 배경색(`backgroundColor`), 외곽선 표시(`showsStroke`), 그림자 표시(`showShadow`)를 옵션으로 제어합니다.
/// - 다크 모드:
///   - `backgroundColor`가 지정되지 않으면 라이트/다크 모드에 따라 적절한 기본 배경색을 사용합니다.
struct UnifiedSectionCard<Content: View>: View {
  @Environment(\.colorScheme) private var colorScheme
  
  /// 카드 내부에 표시할 실제 콘텐츠 뷰입니다.
  let content: Content
  
  /// 카드의 포인트(강조) 색상입니다. 주로 외곽선 색상 계산에 활용됩니다.
  var pointColor: Color?
  
  /// 카드 배경 색상입니다. 지정하지 않으면 라이트/다크 모드에 따른 기본값이 적용됩니다.
  var backgroundColor: Color?
  
  /// 카드 외곽선(stroke) 표시 여부입니다. `true`일 경우 미세한 테두리가 렌더링됩니다.
  var showsStroke: Bool
  
  /// 카드 그림자 표시 여부입니다. `true`일 경우 공통 섀도우 모듈(`UnifiedShadow`)이 적용됩니다.
  var showShadow: Bool
  
  /// 카드 레이아웃 초기화 메서드입니다.
  /// - Parameters:
  ///   - pointColor: 강조 색상(외곽선에 반영). 기본값 `nil`.
  ///   - backgroundColor: 배경 색상. 기본값 `nil`(모드별 기본 배경 사용).
  ///   - showsStroke: 외곽선 표시 여부. 기본값 `true`.
  ///   - showShadow: 그림자 표시 여부. 기본값 `true`.
  ///   - content: 카드 내부에 배치할 콘텐츠 빌더.
  init(
    pointColor: Color? = nil,
    backgroundColor: Color? = nil,
    showsStroke: Bool = true,
    showShadow: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    self.pointColor = pointColor
    self.backgroundColor = backgroundColor
    self.showsStroke = showsStroke
    self.showShadow = showShadow
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      // MARK: - 콘텐츠 영역
      // 섹션 타이틀/본문 등 자식 뷰를 수직 스택으로 배치합니다.
      content
    }
    .padding(.defaultSpacing) // 카드 내부 공통 패딩
    .frame(maxWidth: .infinity, alignment: .leading)
    .fixedSize(horizontal: false, vertical: true)
    // MARK: - 배경
    .background(
      (backgroundColor ?? (
        colorScheme == .dark ? Color.white.opacity(0.3) : Color.white
      ))
    )
    // MARK: - 라운드 처리
    .clipShape(
      RoundedRectangle(
        cornerRadius: .defaultRadius,
        style: .continuous
      )
    )
    // MARK: - 외곽선(선택)
    .overlay(
      Group {
        if showsStroke {
          RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
            .strokeBorder(
              // 포인트 컬러가 있으면 이를 연하게 적용, 없으면 모드별 기본 테두리 사용
              pointColor?.opacity(0.3) ?? (
                colorScheme == .dark
                ? Color.white.opacity(0.15)
                : Color.black.opacity(0.1)
              ),
              lineWidth: 1
            )
        }
      }
    )
    // MARK: - 그림자(선택)
    // 공통 섀도우 모듈을 통해 그림자 강도·표현을 일관되게 적용합니다.
    .modifier(UnifiedShadow(enabled: showShadow))
  }
}

#Preview("stroke") {
  UnifiedSectionCard(pointColor: .main, backgroundColor: nil, showsStroke: false) {
    VStack {
      Text("테스트 뷰")
      Spacer()
      Text("텍스트")
    }
  }
}

#Preview("not") {
  UnifiedSectionCard(pointColor: .main, backgroundColor: nil, showsStroke: false, showShadow: false) {
    VStack {
      Text("테스트 뷰")
      Spacer()
      Text("텍스트")
    }
  }
}
