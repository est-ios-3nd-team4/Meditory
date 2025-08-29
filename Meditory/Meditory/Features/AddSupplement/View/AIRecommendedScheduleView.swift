//
//  AIRecommendedScheduleView.swift
//  Meditory
//
//  Created by 홍승아 on 8/17/25.
//

import SwiftUI
import SwiftData

struct AIRecommendedScheduleView: View {
  
  enum AIPlanState {
    case idle(reason: IdleReason)
    case creating
    case created
    
    enum IdleReason {
      case initial
      case missingSupplementInput
      case networkFailed
      
      var description: String {
        switch self {
        case .missingSupplementInput:
          return "AI 추천 생성을 위해 영양제 정보를 입력해주세요."
        case .networkFailed:
          return "네트워크 오류로 스케줄을 불러올 수 없습니다. 다시 시도해주세요."
        case .initial:
          return ""
        }
      }
    }
    
    var isIdle: Bool {
      if case .idle = self { return true }
      return false
    }
  }
  
  @Environment(\.modelContext) private var context
  @Environment(\.colorScheme) private var colorScheme
  private let isPad = UIDevice.isPad
  
  let supplementSummary: SupplementSummary?
  let lifestyle: UserLifeStyleDTO
  
  @State private var routineAIVM = SupplementRoutineAIViewModel()
  @Binding private var supplement: SupplementDTO?
  @State private var aiPlanState: AIPlanState
  @State private var trigger = false
  @State private var isLifestyleUpdated = false
  @State private var isInitiallyCreated: Bool
  
  init(
    supplementSummary: SupplementSummary?,
    lifestyle: UserLifeStyleDTO?,
    supplement: Binding<SupplementDTO?>
  ) {
    self.supplementSummary = supplementSummary
    self.lifestyle = lifestyle ?? .standard
    self._supplement = supplement
    
    if supplement.wrappedValue != nil {
      aiPlanState = .created
      isInitiallyCreated = true
    } else {
      aiPlanState = .idle(reason: .initial)
      isInitiallyCreated = false
    }
  }
  
  var body: some View {
    VStack {
      let verticalPadding: CGFloat = 15
      
      Spacer()
        .frame(height: aiPlanState.isIdle ? verticalPadding : .zero)
      
      HStack {
        if aiPlanState.isIdle {
          Spacer()
        }
        
        Image("icon_ai_recommend")
          .resizable()
          .frame(width: 20, height: 20)
        
        Text("AI 추천 복용 스케줄")
          .font(.notoSans(size: .defaultFontSize))
        
        Spacer()
        
        if !aiPlanState.isIdle {
          InfoButton()
        }
      }
      
      switch aiPlanState {
      case .idle(let reason):
        Button {
          requestAISchedule()
        } label: {
          Text("생성하기")
            .font(.notoSans(size: .defaultFontSize))
            .foregroundStyle(.main)
        }
        
        switch reason {
        case .missingSupplementInput, .networkFailed:
          Text(reason.description)
            .font(.notoSans(weight: .regular, size: .defaultFontSize - 5))
            .foregroundStyle(.textGray)
            .padding(.top, 4)
            .multilineTextAlignment(.center)
            .modifier(
              ShakeEffect(
                amplitude: 1,
                shakesPerUnit: 3,
                animatableData: trigger ? 1 : 0
              )
            )
            .onAppear {
              withAnimation(.easeInOut(duration: 0.6)) {
                trigger.toggle()
              }
            }
        default: EmptyView()
        }
      case .creating:
        let scales: [CGFloat] = [0.4, 0.6, 0.5]
        
        VStack(alignment: .leading, spacing: .smallSpacing) {
          ForEach(Array(scales.enumerated()), id: \.offset) { idx, scale in
            ShimmerView(widthRatio: scale)
              .frame(height: isPad ? 18 : 15)
          }
        }
      case .created:
        updateScheduleSection()
        
        if let supplement {
          ForEach(Array(supplement.schedule.times.enumerated()), id: \.offset) { index, doseTime in
            scheduleInfoRow(index: index, doseTime: doseTime)
          }
        }
      }
      
      Spacer()
        .frame(height: aiPlanState.isIdle ? verticalPadding : 0)
    }
    .padding(.defaultSpacing)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
        .stroke(
          LinearGradient(
            gradient: Gradient(stops: [
              .init(color: .init(red: 0, green: 122, blue: 255), location: 0.0),
              .init(color: .init(red: 229, green: 114, blue: 255), location: 0.44),
              .init(color: .init(red: 155, green: 139, blue: 255), location: 0.51),
              .init(color: .init(red: 68, green: 112, blue: 247), location: 0.54),
              .init(color: .init(red: 35, green: 138, blue: 249), location: 1.0),
            ]),
            startPoint: .leading,
            endPoint: .trailing
          )
          ,
          lineWidth: 2
        )
        .modifier(UnifiedShadow())
    )
    .onReceive(NotificationCenter.default.publisher(for: .didUpdateLifestyle)) { _ in
      guard !isLifestyleUpdated else { return }
      isLifestyleUpdated = true
    }
  }
}


// MARK: - Subviews
extension AIRecommendedScheduleView {
  private func scheduleInfoRow(index: Int, doseTime: DoseTime) -> some View {
    HStack(spacing: .defaultSpacing) {
      let circleWidth: CGFloat = isPad ? 25 : 18
      
      ZStack {
        Circle()
          .fill(.main)
          .frame(width: circleWidth, height: circleWidth)
        
        Text("\(index + 1)")
          .font(.notoSans(weight: .bold, size: .defaultFontSize - 8))
          .foregroundStyle(.white)
          .padding(.bottom, 1)
      }
      
      Text(doseTime.timeString)
        .font(.notoSans(weight: .regular, size: .defaultFontSize))
        .padding(.bottom, 2)
      
      HStack(spacing: 4) {
        Text(doseTime.relativeTo)
          .font(.notoSans(weight: .semiBold, size: .defaultFontSize - 6))
          .foregroundStyle(.main)
        
        if doseTime.isNotNone {
          Text(doseTime.relativeTimeDescription)
            .font(.notoSans(size: .defaultFontSize - 6))
            .foregroundStyle(.main)
        }
      }
      .padding(.horizontal, isPad ? .smallSpacing + 4 : .smallSpacing)
      .padding(.vertical, isPad ? 4 : 2)
      .background(
        Capsule()
          .fill(.sub.opacity(0.18))
      )
      
      Spacer()
      
      Text(doseTime.doseString)
        .font(.notoSans(weight: .regular, size: .defaultFontSize))
        .foregroundStyle(.textGray)
        .padding(.bottom, 2)
    }
  }
  
  @ViewBuilder
  private func updateScheduleSection() -> some View {
    if isLifestyleUpdated || isInitiallyCreated {
      let prefixText = isLifestyleUpdated ? "변경된 생활 패턴에 맞춰  " : "AI 추천 스케줄  "
      let actionText = isLifestyleUpdated ? "스케줄 새로 추천받기" : "다시 생성하기"
      
      Button {
        requestAISchedule()
      } label: {
        HStack(spacing: .zero) {
          Text(prefixText)
            .font(.notoSans(weight: .regular, size: .defaultFontSize - 5))
            .foregroundStyle(.textGray)
          
          Text(actionText)
            .font(.notoSans(size: .defaultFontSize - 5))
            .foregroundStyle(.main)
        }
        .padding(.bottom, .smallSpacing)
        .padding(.top, -4)
      }
    }
  }
}


// MARK: - Network
extension AIRecommendedScheduleView {
  private func requestAISchedule() {
    guard let supplementSummary, supplementSummary.type < 3 else {
      aiPlanState = .idle(reason: .missingSupplementInput)
      return
    }
    
    withAnimation {
      aiPlanState = .creating
      isLifestyleUpdated = false
    }
    
    Task {
      do {
        let result = try await routineAIVM.requestAISchedule(
          supplementName: supplementSummary.name,
          lifeStyle: lifestyle,
          context: context
        )
        supplement = result
        
        aiPlanState = .created
      } catch {
        aiPlanState = .idle(reason: .networkFailed)
        print("❌ Error is \(error)")
      }
    }
  }
}


// MARK: - ShakeEffect
fileprivate struct ShakeEffect: GeometryEffect {
  /// 흔드는 강도
  var amplitude: CGFloat
  /// 몇 번 흔들릴지
  var shakesPerUnit: CGFloat
  /// 애니메이션이 진행되는 정도 (0 → 1)
  var animatableData: CGFloat
  
  func effectValue(size: CGSize) -> ProjectionTransform {
    let x = amplitude * sin(animatableData * .pi * shakesPerUnit)
    return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
  }
}
