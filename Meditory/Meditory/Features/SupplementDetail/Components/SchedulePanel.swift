//
//  SchedulePanel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SchedulePanel: View {
  let title: String
  let badge: String?
  let times: [String]
  let cycle: String
  let highlighted: Bool
  let colorScheme: ColorScheme
  let accent: Color?

  var body: some View {
    let accentColor = (accent ?? .main)

    VStack(alignment: .leading, spacing: .defaultSpacing) {
      HStack(spacing: .smallSpacing) {
        Text(title)
          .font(.notoSans(size: 16))
          .fontWeight(.bold)
          .foregroundStyle(highlighted ? accentColor : Color.primary)

        if let badge {
          Text(badge)
            .font(.notoSans(weight: .bold, size: 12))
            .padding(.horizontal, .smallSpacing)
            .padding(.vertical, .smallSpacing/2)
            .background(
              Capsule().fill(
                (highlighted ? accentColor : Color.blue).opacity(0.15)
              )
            )
            .foregroundStyle(highlighted ? accentColor : .blue)
        }
        Spacer()
      }

      VStack(alignment: .leading, spacing: .smallSpacing) {
        ForEach(times, id: \.self) { t in
          ScheduleDisplayRow(icon: "alarm", text: t)
        }
        ScheduleDisplayRow(icon: "repeat", text: cycle)
      }
    }
    .padding(.defaultSpacing)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(colorScheme == .dark ? Color.white.opacity(0.08) : Color(.secondarySystemGroupedBackground))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .stroke(highlighted ? accentColor.opacity(0.6) : Color.clear, lineWidth: 1.5)
    )
    .animation(.easeInOut(duration: 0.15), value: highlighted)
  }
}
#Preview("Mine") {
    SchedulePanel(
        title: "내 일정",
        badge: nil,
        times: ["오전 8시", "오후 8시"],
        cycle: "매일",
        highlighted: true,
        colorScheme: .light,
        accent: .orange
    )
    .padding()
    .background(Color.customBackground)
}

#Preview("AI") {
    SchedulePanel(
        title: "AI 일정",
        badge: "추천",
        times: ["오전 7시", "오후 7시"],
        cycle: "매일",
        highlighted: true,
        colorScheme: .light,
        accent: .main
    )
    .padding()
    .background(Color.customBackground)
}
