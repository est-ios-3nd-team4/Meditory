//
//  OnboardingPage.swift
//  Meditory
//
//  Created by 윤혜주 on 8/28/25.
//


import SwiftUI

/// 온보딩 각 페이지를 나타내는 모델입니다.
/// - `Identifiable`, `Equatable`을 채택하여 리스트/탭 전환에 활용합니다.
/// - `imageName`는 에셋 카탈로그의 이미지 이름을 의미합니다.
struct OnboardingPage: Identifiable, Equatable {
  /// 페이지 식별자
  let id = UUID()
  /// 페이지 상단 제목
  let title: String
  /// 제목 아래 보조 설명
  let subtitle: String
  /// 온보딩 일러스트 이미지 이름(에셋)
  let imageName: String
}

/// 온보딩 화면 공통 테마 상수 모음입니다.
/// - 카드 최소 높이, 인디케이터 패딩, 디바이스별 가로 최대 폭 및 비율을 정의합니다.
private enum OBTheme {
  /// 온보딩 카드 최소 높이
  static let minCardHeight: CGFloat = 640
  /// 페이지 인디케이터 위쪽 패딩
  static let dotsTopPadding: CGFloat = 8
  /// 페이지 인디케이터 아래쪽 패딩
  static let dotsBottomPadding: CGFloat = 8
  /// iPhone에서 모형(mock) 콘텐츠 최대 가로 폭
  static let mockMaxWidthPhone: CGFloat = 420
  /// iPad에서 모형(mock) 콘텐츠 최대 가로 폭
  static let mockMaxWidthPad: CGFloat = 620
  /// iPhone에서 모형(mock) 가로 비율
  static let mockWidthRatioPhone: CGFloat = 0.88
  /// iPad에서 모형(mock) 가로 비율
  static let mockWidthRatioPad: CGFloat = 0.72
}

/// 앱 소개 온보딩 전체 화면입니다.
/// - 구성:
///   - 상단: “건너뛰기/시작하기” 버튼 + 페이지 인디케이터
///   - 본문: `TabView`로 페이지 스와이프
/// - 동작:
///   - 마지막 페이지에서 버튼 문구가 “시작하기”로 전환됩니다.
///   - 버튼 탭 시 페이드 아웃 애니메이션 후 `hasSeenOnboarding = true`로 변경됩니다(애니메이션 부작용 방지 위해 `Transaction` 사용).
struct IntroduceOnboardingView: View {
  /// 온보딩 노출 여부(외부 바인딩)
  @Binding var hasSeenOnboarding: Bool
  /// 마지막 페이지 여부
  private var isLastPage: Bool { index == pages.count - 1 }
  /// 페이드 아웃 중 여부(탭 차단/투명도 제어)
  @State private var isFadingOut = false
  /// 페이드 아웃 지속 시간
  private let fadeDuration: Double = 0.35
  
  /// 온보딩 페이지 데이터
  @State private var pages: [OnboardingPage] = [
    .init(title: "오늘 먹은 영양제",
          subtitle: "섭취 현황을 한눈에 확인하세요",
          imageName: "img_Onboarding_1"),
    .init(title: "복용 주기·시간 고민 없이",
          subtitle: "AI가 맞춤 스케줄을 추천해줘요",
          imageName: "img_Onboarding_2"),
    .init(title: "영양제 사기 전에 필수!",
          subtitle: "영양제 성분, 효과 확인해요",
          imageName: "img_Onboarding_3"),
    .init(title: "오늘 먹은 식단 기록하고",
          subtitle: "부족한 영양소를 확인해요",
          imageName: "img_Onboarding_4"),
    .init(title: "과도한지 부족하지?",
          subtitle: "내 영양제 AI로 분석해보세요",
          imageName: "img_Onboarding_5")
  ]
  
  /// 현재 페이지 인덱스
  @State private var index: Int = 0
  
  /// iPad 스타일 여부
  private var isPadStyle: Bool { UIDevice.isPad }
  /// 상단 버튼 폰트 크기
  private var buttonFontSize: CGFloat { isPadStyle ? 25 : 15 }
  
  var body: some View {
    ZStack {
      // 배경 색상
      Color.background.ignoresSafeArea(.all)
      
      // 페이지 스와이프 영역
      TabView(selection: $index) {
        ForEach(Array(pages.enumerated()), id: \.offset) { offset, page in
          OnboardingCard(
            isPadStyle: isPadStyle,
            page: page,
            indicatorIndex: index,
            indicatorCount: pages.count
          )
          .tag(offset)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .ignoresSafeArea(.all)
      .tabViewStyle(.page(indexDisplayMode: .never)) // 기본 인디케이터 숨김
      .animation(.easeInOut, value: index)
    }
    .ignoresSafeArea()
    .compositingGroup()
    .opacity(isFadingOut ? 0 : 1)                 // 페이드 아웃
    .allowsHitTesting(!isFadingOut)               // 전환 중 입력 차단
    .safeAreaInset(edge: .top) {
      // 상단 버튼 + 페이지 인디케이터
      VStack(spacing: .smallSpacing) {
        HStack {
          Spacer()
          Button(action: {
            // 페이드 아웃 → 상태 전환(애니메이션 비활성 트랜잭션)
            withAnimation(.easeInOut(duration: fadeDuration)) {
              isFadingOut = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
              var transaction = Transaction()
              transaction.disablesAnimations = true
              
              withTransaction(transaction) {
                hasSeenOnboarding = true
              }
            }
          }) {
            Text(isLastPage ? "시작하기" : "건너뛰기")
              .contentTransition(.opacity)
              .animation(.easeInOut(duration: 0.20), value: isLastPage)
              .font(.notoSans(size: buttonFontSize))
              .foregroundStyle(Color.main)
          }
        }
        .padding(.trailing, .defaultSpacing)
        
        PageIndicator(count: pages.count, index: index, isPadStyle: isPadStyle)
      }
      .padding(.top, .smallSpacing)
    }
  }
}

/// 온보딩 페이지 위치를 나타내는 인디케이터입니다.
/// - `count`와 `index`에 따라 채워진 점/빈 점을 렌더링합니다.
/// - 접근성 요소로서 숨김 처리(`accessibilityHidden`)가 적용되어 있습니다(중복 낭독 방지).
struct PageIndicator: View {
  /// 총 페이지 수
  let count: Int
  /// 현재 페이지 인덱스
  let index: Int
  /// iPad 스타일 여부
  let isPadStyle: Bool
  
  /// 점 크기
  private var dotSize: CGFloat { isPadStyle ? 15 : 10 }
  /// 점 간격
  private var dotSpacing: CGFloat { isPadStyle ? .defaultSpacing : .smallSpacing }
  
  var body: some View {
    HStack(spacing: dotSpacing) {
      ForEach(0..<count, id: \.self) { i in
        Circle()
          .fill(i == index ? Color.main : Color.secondary.opacity(0.3))
          .frame(width: dotSize, height: dotSize)
          .accessibilityHidden(true)
      }
    }
    .padding(.vertical, .smallSpacing)
  }
}

/// 온보딩 단일 페이지 카드 UI입니다.
/// - 상단: 제목/부제목
/// - 중앙: 온보딩 일러스트 이미지
/// - 하단: 여백
/// - 디바이스별(Phone/iPad) 타이포/패딩/이미지 비율을 조정합니다.
struct OnboardingCard: View {
  /// iPad 스타일 여부
  let isPadStyle: Bool
  
  /// 제목 폰트 크기
  private var titleFontSize: CGFloat { isPadStyle ? 38 : 25 }
  /// 부제목 폰트 크기
  private var subTitleFontSize: CGFloat { isPadStyle ? 40 : 27 }
  /// 상단 패딩
  private var topPadding: CGFloat { isPadStyle ? 120 : 100 }
  /// 제목-이미지 사이 하단 패딩
  private var bottomPadding: CGFloat { isPadStyle ? 100: 10 }
  /// 전체 수직 오프셋(상단 여백 보정)
  private var verticalOffset: CGFloat { isPadStyle ? 120 : 80 }
  /// 이미지 가로 폭 비율
  private var imageRatio: CGFloat { isPadStyle ? 0.8 : 0.9 }
  
  /// 표시할 페이지 데이터
  let page: OnboardingPage
  /// 현재 인디케이터 인덱스(스타일 변형 시 참고 가능)
  let indicatorIndex: Int
  /// 전체 인디케이터 개수
  let indicatorCount: Int
  
  var body: some View {
    GeometryReader { geo in
      // 디바이스·화면 폭을 고려한 이미지 폭 계산
      let ratio = isPadStyle ? OBTheme.mockWidthRatioPad : OBTheme.mockWidthRatioPhone
      let cap = isPadStyle ? OBTheme.mockMaxWidthPad   : OBTheme.mockMaxWidthPhone
      let mockWidth = min(geo.size.width * ratio, cap)
      
      VStack(spacing: 30) {
        // 타이틀/서브타이틀
        VStack(spacing: .smallSpacing) {
          Text(page.title)
            .font(.notoSans(size: titleFontSize))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
          
          Text(page.subtitle)
            .font(.notoSans(weight: .bold, size: subTitleFontSize))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .minimumScaleFactor(0.9)
            .lineLimit(2)
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        
        // 온보딩 대표 이미지
        Image(page.imageName)
          .resizable()
          .interpolation(.high)
          .antialiased(true)
          .renderingMode(.original)
          .scaledToFit()
          .frame(width: mockWidth * imageRatio)
          .modifier(UnifiedShadow())
          .accessibilityHidden(true)
        
        Spacer(minLength: 0)
      }
      .offset(y: verticalOffset)
      .padding(.horizontal, .smallSpacing)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.background.ignoresSafeArea(.all))
    }
    .frame(minHeight: OBTheme.minCardHeight, maxHeight: .infinity)
    .background(Color.background.ignoresSafeArea(.all))
  }
}

// MARK: - Previews
#if DEBUG
/// 온보딩 화면 미리보기용 래퍼입니다.
private struct IntroduceOnboardingView_PreviewWrapper: View {
  @State private var seen = false
  var body: some View {
    IntroduceOnboardingView(hasSeenOnboarding: $seen)
  }
}

#Preview {
  IntroduceOnboardingView_PreviewWrapper()
}
#endif
