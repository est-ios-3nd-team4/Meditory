//
//  SplitScheduleCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SplitScheduleCard: View {
  @Environment(\.colorScheme) private var colorScheme
  @Binding var selectedTab: PlanTab

  let userTimes: [String], userCycle: String
  let recTimes: [String], recCycle: String

  var body: some View {
    VStack(alignment: .leading) {
      Text("복용 스케줄")
        .font(.notoSans(weight: .bold, size: 18))

      HStack(alignment: .top, spacing: .defaultSpacing) {
        SchedulePanel(
          title: "내 일정",
          badge: nil,
          times: userTimes,
          cycle: userCycle,
          highlighted: selectedTab == .mine,
          colorScheme: colorScheme,
          accent: .orange
        )
        .cornerRadius(20)
        .modifier(UnifiedShadow())
        .onTapGesture {
          withAnimation(.easeInOut(duration: 0.15)) { selectedTab = .mine }
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

        SchedulePanel(
          title: "AI 일정",
          badge: "추천",
          times: recTimes,
          cycle: recCycle,
          highlighted: selectedTab == .ai,
          colorScheme: colorScheme,
          accent: .main
        )
        .cornerRadius(20)
        .modifier(UnifiedShadow())
        .onTapGesture {
          withAnimation(.easeInOut(duration: 0.15)) { selectedTab = .ai }
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
      }

      if selectedTab == .mine {
        NavigationLink {
          AddSupplementView()
        } label: {
          HStack(spacing: .smallSpacing) {
            Image(systemName: "pencil.circle.fill")
            Text("내 일정 수정하러 가기")
              .font(.notoSans(weight: .bold, size: 17))
            Spacer()
            Image(systemName: "chevron.right")
          }
          .padding(.vertical, .defaultSpacing)
          .padding(.horizontal, .defaultSpacing)
          .background(Color.orange)
          .foregroundStyle(.white)
          .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("내 일정 수정 화면으로 이동")
      } else {
        NavigationLink {
          AddSupplementView()
        } label: {
          HStack(spacing: .smallSpacing) {
            Image(systemName: "pencil.circle.fill")
            Text("AI 추천 일정 적용하러 가기")
              .font(.notoSans(weight: .bold, size: 17))
            Spacer()
            Image(systemName: "chevron.right")
          }
          .padding(.vertical, .defaultSpacing)
          .padding(.horizontal, .defaultSpacing)
          .background(Color.main)
          .foregroundStyle(.white)
          .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("내 일정 수정 화면으로 이동")
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.defaultSpacing)
    .background(
      colorScheme == .dark
      ? Color.white.opacity(0.3)
      : Color.white
    )
    .cornerRadius(20)
    .modifier(UnifiedShadow())
  }
}
#Preview("Mine") {
  @Previewable @State var selectedTab: PlanTab = .mine
    return SplitScheduleCard(
        selectedTab: $selectedTab,
        userTimes: ["오전 8시", "오후 8시","오전 8시", "오후 8시"],
        userCycle: "매일",
        recTimes: ["오전 7시", "오후 7시"],
        recCycle: "매일"
    )
    .padding()
    .background(Color.customBackground)
}

#Preview("AI") {
  @Previewable @State var selectedTab: PlanTab = .ai
    return SplitScheduleCard(
        selectedTab: $selectedTab,
        userTimes: ["오전 8시", "오후 8시"],
        userCycle: "매일",
        recTimes: ["오전 7시", "오후 7시"],
        recCycle: "매일"
    )
    .padding()
    .background(Color.customBackground)
}

