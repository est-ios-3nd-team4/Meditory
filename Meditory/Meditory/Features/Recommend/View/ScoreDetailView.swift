import SwiftUI

/// 영양 점수 및 상세 분석 결과를 보여주는 화면
struct ScoreDetailView: View {
  /// 현재 뷰 닫기 위한 dismiss 액션
  @Environment(\.dismiss) private var dismiss
  /// 다크/라이트 모드
  @Environment(\.colorScheme) private var colorScheme

  /// 점수 및 분석 결과
  let result: ScoreResult

  /// 점수(Double 변환)
  private var score: Double { Double(result.score) }
  /// 카테고리별 영양 상태 개수
  private var counts: ScoreCounts { result.counts }

  /// 게이지 애니메이션 진행률
  @State private var animatedProgress: Double = 0
  
  var body: some View {
    VStack {
      HeaderBar(score: Int(score), dismiss: dismiss)
      
      ZStack {
        // 배경 카드
        RoundedRectangle(cornerRadius: .defaultRadius)
          .fill(colorScheme == .dark ? Color.black : Color.customBackground)
        
        VStack(spacing: .defaultSpacing) {
          // 원형 게이지
          ScoreGauge(progress: animatedProgress, score: Int(score))
          
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

/// 상단 헤더 (뒤로가기 버튼 + 제목 + 점수)
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

/// 원형 게이지 (점수 시각화)
private struct ScoreGauge: View {
  @Environment(\.colorScheme) private var colorScheme
  /// 게이지 진행률 (0.0 ~ 1.0)
  let progress: Double
  /// 실제 점수
  let score: Int
  var body: some View {
    ZStack(alignment: .center) {
      // 바탕 원
      Circle()
        .trim(from: 0, to: 1)
        .stroke(
          colorScheme == .dark ? Color.white : Color.gray.opacity(0.3),
          style: StrokeStyle(lineWidth: 30, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .padding(5)

      // 진행 원
      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          Color.main,
          style: StrokeStyle(lineWidth: 40, lineCap: .butt)
        )
        .rotationEffect(.degrees(-90))

      // 점수 텍스트
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

/// 카테고리별 영양 상태 통계 행
private struct StatRow: View {
  /// 개별 항목 데이터
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

  /// 개별 통계 카드
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
