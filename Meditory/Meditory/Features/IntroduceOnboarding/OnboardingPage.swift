//
//  OnboardingPage.swift
//  Meditory
//
//  Created by 윤혜주 on 8/28/25.
//


import SwiftUI

struct OnboardingPage: Identifiable, Equatable {
  let id = UUID()
  let title: String
  let subtitle: String
  let imageName: String
}

private enum OBTheme {
  static let minCardHeight: CGFloat = 640
  static let dotsTopPadding: CGFloat = 8
  static let dotsBottomPadding: CGFloat = 8
  static let mockMaxWidth: CGFloat = 420
  static let mockWidthRatio: CGFloat = 0.88
}

struct IntroduceOnboardingView: View {
  @Binding var hasSeenOnboarding: Bool
  private var isLastPage: Bool { index == pages.count - 1 }
  @State private var isFadingOut = false
   private let fadeDuration: Double = 0.35

  @State private var pages: [OnboardingPage] = [
    .init(
      title: "오늘 먹은 영양제",
      subtitle: "섭취 현황을 한눈에 확인하세요",
      imageName: "img_Onboarding_1"
    ),
    .init(
      title: "복용 주기·시간 고민 없이",
      subtitle: "AI가 맞춤 스케줄을 추천해줘요",
      imageName: "img_Onboarding_2"
    ),
    .init(
      title: "영양제 사기 전에 필수!",
      subtitle: "영양제 성분, 효과 확인해요",
      imageName: "img_Onboarding_3"
    ),
    .init(
      title: "오늘 먹은 식단 기록하고",
      subtitle: "부족한 영양소를 확인해요",
      imageName: "img_Onboarding_4"
    ),
    .init(
      title: "과도한지 부족하지?",
      subtitle: "내 영양제 AI로 분석해보세요",
      imageName: "img_Onboarding_5"
    )
  ]

  @State private var index: Int = 0
  @Environment(\.horizontalSizeClass) private var hSize

  private var isPadStyle: Bool { hSize == .regular }
  private var buttonFontSize: CGFloat { isPadStyle ? 17 : 15 }

  var body: some View {
    ZStack {
      Color.background.ignoresSafeArea()

      TabView(selection: $index) {
        ForEach(Array(pages.enumerated()), id: \.offset) { offset, page in
          OnboardingCard(page: page, indicatorIndex: index, indicatorCount: pages.count)
            .tag(offset)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .animation(.easeInOut, value: index)
    }
    .ignoresSafeArea()
    .compositingGroup()
    .opacity(isFadingOut ? 0 : 1)
    .allowsHitTesting(!isFadingOut)
    .safeAreaInset(edge: .top) {
      VStack(spacing: .smallSpacing) {
        HStack {
          Spacer()
          Button(action: {
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
        PageIndicator(count: pages.count, index: index)
      }
      .padding(.top, .smallSpacing)
    }
  }
}

struct PageIndicator: View {
  let count: Int
  let index: Int

  var body: some View {
    HStack(spacing: .smallSpacing) {
      ForEach(0..<count, id: \.self) { i in
        Circle()
          .fill(i == index ? Color.main : Color.secondary.opacity(0.3))
          .frame(width: 10, height: 10)
          .accessibilityHidden(true)
      }
    }
    .padding(.vertical, .smallSpacing)
  }
}

struct OnboardingCard: View {
  @Environment(\.horizontalSizeClass) private var hSize
  private var isPadStyle: Bool { hSize == .regular }
  private var titleFontSize: CGFloat { isPadStyle ? 27 : 25 }
  private var subTitleFontSize: CGFloat { isPadStyle ? 29 : 27 }

  let page: OnboardingPage
  let indicatorIndex: Int
  let indicatorCount: Int

  var body: some View {
    GeometryReader { geo in
      let mockWidth = min(geo.size.width * OBTheme.mockWidthRatio, OBTheme.mockMaxWidth)

      VStack(spacing: 30) {
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
            .minimumScaleFactor(0.92)
            .lineLimit(2)
        }
        .padding(.top, 60)
        .padding(.bottom, 30)

        Image(page.imageName)
          .resizable()
          .interpolation(.high)
          .antialiased(true)
          .renderingMode(.original)
          .scaledToFit()
          .frame(width: mockWidth * 0.9)
          .modifier(UnifiedShadow())
          .accessibilityHidden(true)

        Spacer(minLength: 0)
      }
      .offset(y: 100)
      .padding(.horizontal)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.background)
    }
    .frame(minHeight: OBTheme.minCardHeight, maxHeight: .infinity)
    .background(Color.background)
  }
}
// MARK: - Previews
#if DEBUG
import SwiftUI

/// 바인딩이 필요한 뷰를 위한 래퍼
private struct IntroduceOnboardingView_PreviewWrapper: View {
  @State private var seen = false
  var body: some View {
    IntroduceOnboardingView(hasSeenOnboarding: $seen)
  }
}

#Preview("iPhone • Light") {
  IntroduceOnboardingView_PreviewWrapper()
    .environment(\.horizontalSizeClass, .compact)
    .preferredColorScheme(.light)
    .previewDevice("iPhone 15 Pro")
}

#Preview("iPhone • Dark") {
  IntroduceOnboardingView_PreviewWrapper()
    .environment(\.horizontalSizeClass, .compact)
    .preferredColorScheme(.dark)
    .previewDevice("iPhone 15 Pro")
}

#Preview("iPad • Landscape") {
  IntroduceOnboardingView_PreviewWrapper()
    .environment(\.horizontalSizeClass, .regular)
    .previewInterfaceOrientation(.landscapeLeft)
    .preferredColorScheme(.light)
    .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

/// 단일 카드 프리뷰 (디자인 확인용)
#Preview("OnboardingCard Only") {
  let sample = OnboardingPage(
    title: "복용 주기·시간 고민 없이",
    subtitle: "AI가 맞춤 스케줄을 추천해줘요",
    imageName: "img_Onboarding_2"
  )
  return OnboardingCard(page: sample, indicatorIndex: 1, indicatorCount: 5)
    .frame(height: 720)
    .padding()
    .background(Color.background)
    .previewLayout(.sizeThatFits)
}
#endif
