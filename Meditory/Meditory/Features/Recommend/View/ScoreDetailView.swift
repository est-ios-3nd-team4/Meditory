import SwiftUI

struct ScoreDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  
  let result: ScoreResult
  
  private var score: Double { Double(result.score) }
  private var counts: ScoreCounts { result.counts }
  
  @State private var animatedProgress: Double = 0
  
  var body: some View {
    VStack {
      HeaderBar(score: Int(score), dismiss: dismiss)
      
      ZStack {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .fill(colorScheme == .dark ? Color.black : Color.customBackground)
        
        VStack(spacing: .defaultSpacing) {
          ScoreGauge(progress: animatedProgress, score: Int(score)) // 게이지
          
          VStack(spacing: .defaultSpacing) {
            Text("AI 분석결과")
              .font(.notoSans(weight: .bold, size: .defaultFontSize - 3))
              .foregroundColor(Color.accent)
              .padding(.top, .defaultSpacing)
            
            StatRow(
              left: .init(title: "부족", tint: .pink, count: counts.deficient, chipBG: .pink),
              right: .init(title: "주의", tint: .yellow, count: counts.caution, chipBG: .yellow)
            )
            
            StatRow(
              left: .init(title: "최적", tint: Color.accent, count: counts.optimal, chipBG: .blue),
              right: .init(title: "충족", tint: .green, count: counts.adequate, chipBG: .green)
            )
            
            NavigationLink(destination: AnalysisView(result: result)) {
              Text("성분 분석 전체 보기")
                .font(.notoSans(weight: .medium, size: .defaultFontSize - 3))
                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                .padding(16)
                .frame(maxWidth: .infinity)
                .buttonBorderShape(.roundedRectangle) // 원본과 동일
                .background(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
                .cornerRadius(.smallRadius)
                .modifier(UnifiedShadow())
                .padding(.bottom, .defaultSpacing)
            }
          }
        }
        .padding(.horizontal, .defaultSpacing)
        .padding(.top, 50)
        .scrollIndicators(.hidden)
      }
      //.padding(.horizontal, 16)
      .padding(.top, 0)
    }
    .navigationBarHidden(true)
    .background {
      GeometryReader { geo in
        let topH = geo.size.height * 0.5 + geo.safeAreaInsets.top
        VStack(spacing: 0) {
          (colorScheme == .dark ? Color.black : Color.main)
            .frame(height: topH)
            .ignoresSafeArea(edges: .top)
          (colorScheme == .dark ? Color.black : Color.customBackground)
            .ignoresSafeArea()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
      }
    }
    .onAppear {
      animatedProgress = 0
      withAnimation(.easeOut(duration: 1.0)) {
        animatedProgress = max(0, min(1, score / 100))
      }
    }
  }
}

private struct HeaderBar: View {
  let score: Int
  let dismiss: DismissAction
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button { dismiss() } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(.white)
        }
        Spacer()
      }
      .padding(.horizontal, .defaultSpacing)
      .padding(.vertical, 12)
      
      HStack {
        Text("영양제 분석 리포트")
          .font(.notoSans(weight: .bold, size: .defaultFontSize + 7))
          .foregroundColor(.white)
        
        Spacer()
      }
      .padding(.defaultSpacing)
    }
  }
}

private struct ScoreGauge: View {
  @Environment(\.colorScheme) private var colorScheme
  let progress: Double
  let score: Int
  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .trim(from: 0, to: 1)
        .stroke(
          colorScheme == .dark ? Color.white : Color.gray.opacity(0.3), // 원본과 동일
          style: StrokeStyle(lineWidth: 30, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .padding(5)
      
      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          Color.main,
          style: StrokeStyle(lineWidth: 40, lineCap: .butt)
        )
        .rotationEffect(.degrees(-90))
      
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text("\(score)")
          .font(.notoSans(weight: .medium, size: 50))
        Text("점")
          .font(.notoSans(weight: .medium, size: .defaultFontSize + 2))
      }
    }
    .padding(.vertical, .defaultSpacing)
    .frame(maxWidth: .infinity)
    .frame(height: 250)
  }
}

private struct StatRow: View {
  struct Item {
    let title: String
    let tint: Color
    let count: Int
    let chipBG: Color
  }
  let left: Item
  let right: Item
  var body: some View {
    HStack {
      StatCard(item: left)
      StatCard(item: right)
    }
  }
  
  private struct StatCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: Item
    var body: some View {
      HStack {
        Text(item.title)
          .font(.notoSans(weight: .bold, size: .defaultFontSize - 6))
          .foregroundColor(item.tint)
          .padding(.horizontal, .smallSpacing)
          .padding(.vertical, 4)
          .background(
            RoundedRectangle(cornerRadius: .defaultRadius)
              .fill(colorScheme == .dark
                    ? item.chipBG.opacity(0.1)
                    : item.chipBG.opacity(0.2))
          )
        
        Spacer()
        
        Text("\(item.count) 개")
          .font(.notoSans(weight: .medium, size: .defaultFontSize - 6))
      }
      .padding(.defaultSpacing)
      .background(
        RoundedRectangle(cornerRadius: .smallRadius)
          .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
          .modifier(UnifiedShadow())
      )
    }
  }
}
