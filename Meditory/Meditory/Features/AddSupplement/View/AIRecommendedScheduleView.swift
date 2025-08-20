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
    case idle
    case creating
    case created
  }
  
  @Environment(\.colorScheme) private var colorScheme
  
  let defaultFontSize: CGFloat
  let supplementName: String
  let lifestyle: UserLifeStyle
  
  @State private var routineAIVM: SupplementRoutineAIViewModel
  @State private var supplement: SupplementDTO?
  @State private var aiPlanState: AIPlanState = .idle
  
  init(
    defaultFontSize: CGFloat,
    context: ModelContext,
    userStore: UserStore,
    supplementName: String,
    lifestyle: UserLifeStyle
  ) {
    self.defaultFontSize = defaultFontSize
    routineAIVM = SupplementRoutineAIViewModel(context: context, userStore: userStore)
    self.supplementName = supplementName
    self.lifestyle = lifestyle
  }
  
  var body: some View {
    VStack {
      let verticalPadding: CGFloat = 15
      
      Spacer()
        .frame(height: aiPlanState == .idle ? verticalPadding : .zero)
      
      HStack {
        if aiPlanState == .idle {
          Spacer()
        }
        
        Image("icon_ai_recommend")
          .resizable()
          .frame(width: 20, height: 20)
        
        Text("AI 추천 복용 스케줄")
          .font(.notoSans(size: defaultFontSize))
        
        Spacer()
        
        if aiPlanState != .idle {
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
      case .idle:
        Button {
          requestAISchedule()
        } label: {
          Text("생성하기")
            .font(.notoSans(size: defaultFontSize))
            .foregroundStyle(.main)
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
        
        Button {
        
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
        
        if let supplement {
          ForEach(Array(supplement.schedule.times.enumerated()), id: \.offset) { index, doseTime in
            scheduleInfoRow(index: index, doseTime: doseTime)
          }
        }
      }
      
      Spacer()
        .frame(height: aiPlanState == .idle ? verticalPadding : 0)
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
    // TODO: 영양제 검색 결과 없을 때 처리 방식 결정 필요
    guard !supplementName.isEmpty else { return }
    
    withAnimation {
      aiPlanState = .creating
    }
    
    Task {
      do {
        let result = try await routineAIVM.requestAISchedule(supplementName: supplementName, lifeStyle: lifestyle)
        supplement = result
        
        try await Task.sleep(for: .seconds(1))
        
        aiPlanState = .created
      } catch {
        // TODO: 응답 오류시 재생성 처리 필요
        print("❌ Error is \(error)")
      }
    }
  }
}
