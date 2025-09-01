import SwiftUI

/// 사용자의 식단/섭취 패턴을 기반으로
/// 영양 점수를 계산하고 시각화하는 뷰
struct ScoreView: View {
  /// 다크/라이트 모드
  @Environment(\.colorScheme) private var colorScheme

  /// 점수 계산을 담당하는 뷰모델
  @StateObject private var scoreVM = ScoreViewModel()

  /// 현재 사용자 정보
  let user: User?
  /// 식단 기록
  let meals: [Meal]
  /// 점수 계산용 식단 입력
  let diet: DietInput
  /// 분석 기준 기간(일 단위, 기본값: 30일)
  var windowDays: Int = 30

  /// 애니메이션으로 표시되는 점수
  @State private var animatedScore: Double = 0

  /// 점수 업데이트 시 외부로 결과를 전달하는 콜백
  var onResultUpdate: ((ScoreResult) -> Void)? = nil

  /// 화면에 표시되는 점수(Int 변환)
  private var shownScore: Int { Int(animatedScore) }

  /// 실제 계산된 점수(Double)
  private var score: Double { Double(scoreVM.result?.score ?? 0) }

  /// 점수 구간별 상태 메시지
  private var statusMessage: String {
    switch score {
    case 70 ... 100:
      return "매우 우수해요! 이대로 유지하세요."
    case 40 ..< 70:
      return "좋은 편이에요. 조금만 더 신경 써보세요."
    default:
      return "주의가 필요해요. 건강 관리가 필요합니다."
    }
  }

  private var statusEmoji: String {
    switch score {
    case 70 ... 100:
      return "👍🏻"
    case 40 ..< 70:
      return "💪🏻"
    default:
      return "🫵🏻"
    }
  }

  /// 점수 재로딩 키 (사용자 이름 + 식단 수 + 최신 날짜 + 식품 수 + 기간)
  private var reloadKey: String {
    let who = (user?.name ?? "@@").trimmingCharacters(in: .whitespacesAndNewlines)
    let count = meals.count
    let latestTS = meals.first?.date.timeIntervalSince1970 ?? 0
    return "\(who)|\(count)|\(Int(latestTS))|\(diet.foods.count)|\(windowDays)"
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      // 헤더: 타이틀 + 상세보기 버튼
      HStack {
        Text("내 영양 점수는?")
          .font(.notoSans(weight: .medium, size: .defaultFontSize))

        Spacer()

        if let analysisResult = scoreVM.result {
          NavigationLink(destination: ScoreDetailView(result: analysisResult)) {
            Image(systemName: "chevron.right")
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }
        }
      }

      .padding(.top, .defaultSpacing)

      // 반원 게이지
      ZStack(alignment: .bottom) {
        // 배경 게이지
        Circle()
          .trim(from: 0, to: 0.5)
          .stroke(colorScheme == .dark ? Color.white : Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 25, lineCap: .round)
          )
          .rotationEffect(.degrees(180))

        // 점수 게이지
        Circle()
          .trim(from: 0, to: animatedScore / 200)
          .stroke(Color.main, style: StrokeStyle(lineWidth: 25, lineCap: .round)
          )
          .rotationEffect(.degrees(180))

        // 점수 텍스트 + 상태 메시지
        VStack(spacing: 0) {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(Int(animatedScore))")
              .font(.notoSans(weight: .medium, size: 50))

            Text("점")
              .font(.notoSans(weight: .medium, size: .defaultFontSize + 2))
          }
          .padding(.bottom, 24)

          HStack {
            Text(statusEmoji)


            Text(statusMessage)
              .font(.notoSans(weight: .medium, size: .defaultFontSize - 4))
              .foregroundColor(.gray)
          }        }
        .padding(.bottom, 36)
      }
      .padding(.top, .defaultSpacing)
      .frame(maxWidth: .infinity)
      .frame(height: 200)
      .clipped()
    }
    .padding(.horizontal, .defaultSpacing)
    .background(colorScheme == .dark ? Color.white.opacity(0.3)
                : Color.white)
    .cornerRadius(.defaultRadius)
    .modifier(UnifiedShadow())

    // 점수 애니메이션
    .onAppear {
      let target = Double(max(0, min(100, scoreVM.result?.score ?? 0)))
      withAnimation(.easeOut(duration: 0.8)) {
        animatedScore = target
      }
    }

    // 점수 계산 task (reloadKey 기준)
    .task(id: reloadKey) {
      scoreVM.load(
        diet: diet,
        meals: meals,
        user: user,
        windowDays: windowDays,
        weights: .default,
        force: false
      )
    }
    // 결과 변경 시 업데이트
    .onChange(of: scoreVM.result) { oldValue,newValue in
      guard let newValue else { return }
      onResultUpdate?(newValue)
      withAnimation(.easeOut(duration: 1.2)) {
        animatedScore = Double(newValue.score)
      }
    }
  }
}

