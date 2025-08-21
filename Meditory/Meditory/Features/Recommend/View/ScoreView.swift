import SwiftUI

struct ScoreView: View {
  @Environment(\.colorScheme) private var colorScheme

  @StateObject private var scoreVM = ScoreViewModel()

  @State private var animatedScore: Double = 0

  var onResultUpdate: ((ScoreResult) -> Void)? = nil

  private var shownScore: Int { Int(animatedScore) }

  private var score: Double { Double(scoreVM.result?.score ?? 0) }
  // 임시 멘트
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

  var body: some View {
    VStack(alignment: .leading, spacing: .defaultSpacing) {
      HStack {
        Text("내 영양제 점수는?")
          .font(.notoSans(weight: .medium, size: 18))

        Spacer()

        if let analysisResult = scoreVM.result {
          NavigationLink(destination: ScoreDetailView(result: analysisResult)) {
            Image(systemName: "chevron.right")
              .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color.gray)
          }
        }
      }

      .padding(.top, 16)

      ZStack(alignment: .bottom) {
        Circle()
          .trim(from: 0, to: 0.5)
          .stroke(colorScheme == .dark ? Color.white : Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 25, lineCap: .round)
          )
          .rotationEffect(.degrees(180))

        Circle()
          .trim(from: 0, to: animatedScore / 200)
          .stroke(Color.main, style: StrokeStyle(lineWidth: 25, lineCap: .round)
          )
          .rotationEffect(.degrees(180))

        VStack(spacing: 0) {
          HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(Int(animatedScore))")
              .font(.notoSans(weight: .medium, size: 50))

            Text("점")
              .font(.notoSans(weight: .medium, size: 20))
          }
          .padding(.bottom, 24)

          HStack {
            Text(statusEmoji)


            Text(statusMessage)
              .font(.notoSans(weight: .medium, size: 14))
              .foregroundColor(.gray)
          }        }
        .padding(.bottom, 36)
      }
      .padding(.top, 16)
      .frame(maxWidth: .infinity)
      .frame(height: 200)
      .clipped()
    }
    .padding(.horizontal, 16)
    .background(colorScheme == .dark ? Color.white.opacity(0.3)
                : Color.white)
    .cornerRadius(.defaultRadius)
    .modifier(UnifiedShadow())
    .onAppear {
      animatedScore = 0
      if scoreVM.result == nil {
        scoreVM.loadMockIntake()
      } else if let current = scoreVM.result?.score {
        DispatchQueue.main.async {
          withAnimation(.easeOut(duration: 1.2)) { animatedScore = Double(current) }
        }
      }
    }
    
    .onChange(of: scoreVM.result) { newResult in
      guard let newResult else { return }
      onResultUpdate?(newResult)
      withAnimation(.easeOut(duration: 1.2)) {
        animatedScore = Double(newResult.score)
      }
    }
  }
}

#Preview {
  ScoreView()
}
