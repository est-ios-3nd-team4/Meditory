//
//  View+Extension.swift
//  Meditory
//
//  Created by 홍승아 on 8/13/25.
//

import SwiftUI

/// `View` 확장
///
/// 앱 전반에서 자주 사용하는 **스타일, 네비게이션, 반응형 UI, 키보드 제어**
/// 관련 유틸리티 메서드를 제공합니다.
extension View {
  /// 카드 스타일을 적용하는 뷰 수정자
  ///
  /// - Parameters:
  ///   - padding: 내부 패딩 (기본값 `.zero`)
  ///   - cornerRadius: 모서리 둥글기 (기본값 `20`)
  /// - Returns: 카드 스타일이 적용된 뷰
  func cardStyle(padding: CGFloat = .zero, cornerRadius: CGFloat = 20)
  -> some View
  {
    self
      .modifier(CardStyle(padding: padding, cornerRadius: cornerRadius))
  }

  /// 롱프레스 시 팝오버를 표시하는 뷰 수정자
  ///
  /// - Parameter content: 팝오버에 표시할 콘텐츠 뷰
  /// - Returns: 롱프레스 시 팝오버가 표시되는 뷰
  func longPressPopover<Content: View>(
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    modifier(LongPressPopoverModifier(popoverContent: content))
  }

  /// 커스텀 네비게이션 바를 삽입하는 뷰 수정자
  ///
  /// - Parameters:
  ///   - title: 네비게이션 바 타이틀
  ///   - backgroundStyle: 배경 스타일 (기본값 `.custom`)
  ///   - isAtTop: 스크롤이 상단에 위치하는지 여부 (옵셔널)
  ///   - onBackTap: 뒤로가기 버튼 액션 (옵셔널)
  /// - Returns: 상단 네비게이션 바가 적용된 뷰
  func navigationBar(
    _ title: NavigationTitle,
    backgroundStyle: PrimaryNavigationBar.BackgroundStyle = .custom,
    isAtTop: Bool? = nil,
    _ onBackTap: (() -> Void)? = nil
  ) -> some View {
    self
      .navigationBarHidden(true)
      .applyIf(isAtTop != nil) {
        $0.coordinateSpace(CoordinateSpaceName.scroll.coordinateSpace)
      }
      .safeAreaInset(edge: .top) {
        PrimaryNavigationBar(
          title: title,
          backgroundStyle: backgroundStyle,
          isAtTop: isAtTop,
          onBackTap: onBackTap
        )
      }
  }

  /// 조건이 참일 때만 `ViewModifier`를 적용
  ///
  /// - Parameters:
  ///   - condition: 적용 여부
  ///   - modifier: 적용할 `ViewModifier`
  /// - Returns: 조건부로 수정자가 적용된 뷰
  @ViewBuilder
  func applyIf<M: ViewModifier>(
    _ condition: Bool,
    modifier: M
  ) -> some View {
    if condition { self.modifier(modifier) } else { self }}

  /// 조건이 참일 때만 뷰 변환 함수를 적용
  ///
  /// - Parameters:
  ///   - condition: 적용 여부
  ///   - transform: 변환 함수
  /// - Returns: 조건부로 변환이 적용된 뷰
  @ViewBuilder
  func applyIf<Content: View>(
    _ condition: Bool,
    @ViewBuilder transform: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
    } else { self }}

  /// 기기 폭에 따라 글꼴 크기를 조정
  ///
  /// - Parameters:
  ///   - baseSize: 기준 폰트 크기
  ///   - small: 작은 기기 보정치 (기본 `-2`)
  ///   - plus: 큰 기기 보정치 (기본 `+2`)
  ///   - weight: `NotoSans` 폰트 굵기
  /// - Returns: 보정된 크기의 폰트가 적용된 뷰
  func adaptiveFont(
    _ baseSize: CGFloat,
    small: CGFloat = -2,
    plus: CGFloat = +2,
    weight: Font.NotoSansWeight = .regular
  ) -> some View {
    /*
     let size: CGFloat
     switch deviceWidthSize() {
     case .small:
     size = small
     case .regular:
     size = 0
     case .plus:
     size = plus
     }
     let finalSize = baseSize + size
     return self.font(.notoSans(weight: weight, size: finalSize))
     */
    return self.font(.notoSans(weight: weight, size: baseSize))
  }

  /// 기기 폭에 따라 이미지 크기를 조정
  ///
  /// - Parameters:
  ///   - baseSize: 기준 크기
  ///   - small: 작은 기기 보정치 (기본 `-20`)
  ///   - plus: 큰 기기 보정치 (기본 `+10`)
  /// - Returns: 보정된 크기로 조정된 이미지 뷰
  func adaptiveImage(
    _ baseSize: CGFloat,
    small: CGFloat = -20,
    plus: CGFloat = +10
  ) -> some View {
    let size: CGFloat
    switch deviceWidthSize() {
    case .small:
      size = small
    case .regular:
      size = 0
    case .plus:
      size = plus
    }
    let side = max(16, baseSize + size)
    return self.frame(width: side, height: side)
  }

  /// 기기 폭에 따라 패딩 크기를 조정
  ///
  /// - Parameters:
  ///   - edge: 패딩 적용 방향
  ///   - base: 기준 패딩 값
  ///   - small: 작은 기기 보정치 (기본 `-2`)
  ///   - plus: 큰 기기 보정치 (기본 `+2`)
  /// - Returns: 보정된 패딩이 적용된 뷰
  func adaptivePadding(
    _ edge:Edge.Set,
    _ base: CGFloat,
    small: CGFloat = -2,
    plus: CGFloat = +2
  )->some View {
    let size: CGFloat
    switch deviceWidthSize() {
    case .small:
      size = small
    case .regular:
      size = 0
    case .plus:
      size = plus
    }
    let value = max(0, base + size)
    return self.padding(edge, value)
  }

  /// 뷰 탭 시 키보드를 숨기는 수정자
  ///
  /// - Returns: 키보드가 자동으로 닫히는 뷰
  func dismissKeyboardOnTap() -> some View {
    modifier(DismissKeyboardOnTap())
  }
}
