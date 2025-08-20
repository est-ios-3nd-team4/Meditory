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
  
  @Environment(\.colorScheme) private var colorScheme
  
  let defaultFontSize: CGFloat
  let supplementSummary: SupplementSummary?
  let lifestyle: UserLifeStyle
  
  @State private var routineAIVM: SupplementRoutineAIViewModel
  @State private var supplement: SupplementDTO?
  @State private var aiPlanState: AIPlanState = .idle(reason: .initial)
  @State private var trigger = false
  @State private var isLifestyleUpdated = false
  
  init(
    defaultFontSize: CGFloat,
    context: ModelContext,
    userStore: UserStore,
    supplementSummary: SupplementSummary?,
    lifestyle: UserLifeStyle
  ) {
    self.defaultFontSize = defaultFontSize
    routineAIVM = SupplementRoutineAIViewModel(context: context, userStore: userStore)
    self.supplementSummary = supplementSummary
    self.lifestyle = lifestyle
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
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        if !aiPlanState.isIdle {
          Button {
            // TODO: 경고 팝업
            // 이 스케줄은 기상·취침 시간, 식사 패턴, 복용 중인 약물 정보를 기반으로 추천됩니다.
          } label: {
            Image(systemName: "info.circle")
              .font(.system(size: 14, weight: .medium))
              .foregroundStyle(.textGray)
          }
        }
      }
      
      switch aiPlanState {
      case .idle(let reason):
        Button {
          requestAISchedule()
        } label: {
          Text("생성하기")
            .font(.notoSans(size: defaultFontSize))
            .foregroundStyle(.main)
        }
        
        switch reason {
        case .missingSupplementInput, .networkFailed:
          Text(reason.description)
            .font(.notoSans(weight: .regular, size: 13))
            .foregroundStyle(.textGray)
            .padding(.top, 4)
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
              .frame(height: 15)
          }
        }
      case .created:
        if isLifestyleUpdated {
          Button {
            requestAISchedule()
          } label: {
            HStack(spacing: .zero) {
              let fontSize: CGFloat = 13
              Text("변경된 생활 패턴에 맞춰  ")
                .font(.notoSans(weight: .regular, size: fontSize))
                .foregroundStyle(.textGray)
              
              Text("스케줄 새로 추천받기")
                .font(.notoSans(size: fontSize))
                .foregroundStyle(.main)
            }
            .padding(.bottom, .smallSpacing)
            .padding(.top, -4)
          }
        }
        
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
    .onChange(of: lifestyle) { oldValue, newValue in
      if oldValue != newValue {
        isLifestyleUpdated = true
      }
    }
  }
}


extension AIRecommendedScheduleView {
  private func scheduleInfoRow(index: Int, doseTime: DoseTime) -> some View {
    HStack(spacing: .defaultSpacing) {
      ZStack {
        Circle()
          .fill(.main)
          .frame(width: 18, height: 18)
        
        Text("\(index + 1)")
          .font(.notoSans(weight: .bold, size: 10))
          .foregroundStyle(.white)
          .padding(.bottom, 1)
      }
      
      Text(doseTime.timeString)
        .font(.notoSans(weight: .regular, size: defaultFontSize))
        .padding(.bottom, 2)
      
      HStack(spacing: 4) {
        let fontSize: CGFloat = 12
        
        Text(doseTime.relativeTo)
          .font(.notoSans(weight: .semiBold, size: fontSize))
          .foregroundStyle(.main)
        
        if doseTime.isNotNone {
          Text(doseTime.relativeTimeDescription)
            .font(.notoSans(size: fontSize))
            .foregroundStyle(.main)
        }
      }
      .padding(.horizontal, .smallSpacing)
      .padding(.vertical, 2)
      .background(
        Capsule()
          .fill(.sub.opacity(0.18))
      )
      
      Spacer()
      
      Text(doseTime.doseString)
        .font(.notoSans(weight: .regular, size: defaultFontSize))
        .foregroundStyle(.textGray)
        .padding(.bottom, 2)
    }
  }
}


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
          lifeStyle: lifestyle
        )
        supplement = result
        
        try await Task.sleep(for: .seconds(1))
        
        aiPlanState = .created
      } catch {
        aiPlanState = .idle(reason: .networkFailed)
        print("❌ Error is \(error)")
      }
    }
  }
}

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
