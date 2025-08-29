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
  static let mockMaxWidthPhone: CGFloat = 420
  static let mockMaxWidthPad: CGFloat = 620
  static let mockWidthRatioPhone: CGFloat = 0.88
  static let mockWidthRatioPad: CGFloat = 0.72
}

struct IntroduceOnboardingView: View {
  @Binding var hasSeenOnboarding: Bool
  private var isLastPage: Bool { index == pages.count - 1 }
  @State private var isFadingOut = false
  private let fadeDuration: Double = 0.35

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

  @State private var index: Int = 0

  private var isPadStyle: Bool { UIDevice.isPad }
  private var buttonFontSize: CGFloat { isPadStyle ? 25 : 15 }

  var body: some View {
    ZStack {
      Color.background.ignoresSafeArea(.all)

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

        PageIndicator(count: pages.count, index: index, isPadStyle: isPadStyle)
      }
      .padding(.top, .smallSpacing)
    }
  }
}

struct PageIndicator: View {
  let count: Int
  let index: Int
  let isPadStyle: Bool

  private var dotSize: CGFloat { isPadStyle ? 15 : 10 }
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

struct OnboardingCard: View {
  let isPadStyle: Bool

  private var titleFontSize: CGFloat { isPadStyle ? 38 : 25 }
  private var subTitleFontSize: CGFloat { isPadStyle ? 40 : 27 }
  private var topPadding: CGFloat { isPadStyle ? 120 : 100 }
  private var bottomPadding: CGFloat { isPadStyle ? 100: 10 }
  private var verticalOffset: CGFloat { isPadStyle ? 120 : 70 }
  private var imageRatio: CGFloat { isPadStyle ? 0.8 : 0.9 }

  let page: OnboardingPage
  let indicatorIndex: Int
  let indicatorCount: Int

  var body: some View {
    GeometryReader { geo in
      let ratio = isPadStyle ? OBTheme.mockWidthRatioPad : OBTheme.mockWidthRatioPhone
      let cap = isPadStyle ? OBTheme.mockMaxWidthPad   : OBTheme.mockMaxWidthPhone
      let mockWidth = min(geo.size.width * ratio, cap)

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
            .minimumScaleFactor(0.9)
            .lineLimit(2)
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)

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
