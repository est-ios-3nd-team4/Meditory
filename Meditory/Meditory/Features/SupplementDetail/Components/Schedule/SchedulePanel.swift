//
//  SchedulePanel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SchedulePanel: View {
  @Environment(\.colorScheme) private var colorScheme

  let times: [String]
  let cycle: String

  var body: some View {
    let accentColor = Color.orange

    VStack(spacing: .smallSpacing) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack(spacing: .smallSpacing) {
          Image(systemName: "calendar.badge.clock")
            .imageScale(.medium)
            .padding(.smallSpacing)
            .background(Circle().fill(accentColor.opacity(0.15)))
            .foregroundStyle(accentColor)

          Text("복용 스케줄")
            .font(.notoSans(size: 18))

          Spacer()

          NavigationLink {
            AddSupplementView(type: .edit)
          } label: {
            Label("수정", systemImage: "pencil")
              .foregroundStyle(.white)
              .labelStyle(.titleAndIcon)
              .font(.notoSans(size: 13))
              .fontWeight(.semibold)
              .padding(.horizontal, 10)
              .padding(.vertical, 6)
              .background(
                Capsule()
                  .fill(accentColor)
              )
              .overlay(
                Capsule()
                  .stroke(accentColor, lineWidth: 1)
              )
              .foregroundStyle(accentColor)
              .shadow(radius: 2, y: 1)  
          }
          .buttonStyle(.plain)
          .accessibilityLabel("내 일정 수정 화면으로 이동")
        }

        SectionHeader(title: "시간", systemImage: "clock")

        VStack(spacing: 0) {
          ForEach(times.indices, id: \.self) { index in
            let time = times[index]
            TimeRow(timeText: time, accent: accentColor)

            if index < times.count - 1 {
              Divider()
                .background(.secondary.opacity(0.2))
                .padding(.leading, 40)
            }
          }
        }

        Divider()
          .background(accentColor.opacity(0.5))
          .padding(.vertical, .smallSpacing)

        SectionHeader(title: "주기", systemImage: "arrow.triangle.2.circlepath")

        HStack(spacing: .defaultSpacing) {
          IconBadge(
            systemName: "repeat",
            backgroundColor: accentColor.opacity(0.12),
            foregroundColor: accentColor
          )

          Text(cycle)
            .font(.notoSans(size: 15))
            .foregroundStyle(.secondary)

          Spacer()
        }
        .padding(.top, .defaultSpacing)
      }
      .padding(.defaultSpacing)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
          .fill(colorScheme == .dark
                ? Color.white.opacity(0.08)
                : Color(.secondarySystemGroupedBackground))
      )
      .modifier(UnifiedShadow())
      .overlay(
        RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
          .stroke(accentColor.opacity(0.6), lineWidth: 1.0)
      )
    }
  }
}

private struct SectionHeader: View {
  let title: String
  let systemImage: String

  var body: some View {
    HStack(spacing: .smallSpacing / 2) {
      ZStack {
        Circle()
          .fill(Color.main)
          .frame(width: 20, height: 20)

        Image(systemName: systemImage)
          .resizable()
          .scaledToFit()
          .frame(width: 10, height: 10)
          .foregroundStyle(.white)
      }

      Text(title)
        .font(.notoSans(size: 13))
        .foregroundStyle(.main)
    }
    .padding(.horizontal, .smallSpacing)
    .padding(.vertical, .smallSpacing / 2)
    .background(Color.blue.opacity(0.1), in: Capsule())
  }
}

private struct TimeRow: View {
  let timeText: String
  let accent: Color

  var body: some View {
    HStack(spacing: .defaultSpacing) {
      IconBadge(
        systemName: "clock.fill",
        backgroundColor: accent.opacity(0.12),
        foregroundColor: accent
      )

      let comps = timeText.split(separator: " ").map(String.init)
      let period = comps.first ?? ""
      let hm = comps.dropFirst().joined(separator: " ")

      HStack(alignment: .firstTextBaseline, spacing: .smallSpacing) {

        Text(period)
          .font(.notoSans(size: 14))
          .foregroundStyle(.secondary)
          .fontWeight(.semibold)

        Text(hm)
          .font(.notoSans(size: 14))
          .foregroundStyle(.secondary)
      }

      Spacer()
    }
    .padding(.vertical, .smallSpacing)
  }
}

private struct IconBadge: View {
  let systemName: String
  let backgroundColor: Color
  let foregroundColor: Color

  var body: some View {
    ZStack {
      Circle()
        .fill(backgroundColor)

      Image(systemName: systemName)
        .font(.notoSans(size: 14))
        .fontWeight(.semibold)
        .foregroundStyle(foregroundColor)
    }
    .frame(width: 28, height: 28)
  }
}

#Preview("Mine") {
  NavigationStack {
    SchedulePanel(
      times: ["오전 8시", "오후 8시"],
      cycle: "매일"
    )
    .padding()
    .background(Color.customBackground)
  }
}
