//
//  SchedulePanel.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SchedulePanel: View {
  
  @Environment(\.modelContext) private var context
  @Environment(\.colorScheme) private var colorScheme

  let times: [String]
  let cycle: String
  let pills: [String]

  var body: some View {
    UnifiedSectionCard(pointColor: Color.orange) {
      HStack(spacing: .smallSpacing) {
        Image(systemName: "calendar.badge.clock")
          .imageScale(.medium)
          .padding(.smallSpacing)
          .background(
            Circle().fill(Color.orange.opacity(0.15))
          )
          .foregroundStyle(.orange)
          .accessibilityHidden(true)

        Text("복용 스케줄")
          .font(.notoSans(size: 18))
          .fontWeight(.bold)

        Spacer()
      }

      VStack(alignment: .leading, spacing: .smallSpacing) {
        SectionHeader(title: "시간", systemImage: "clock")

        VStack(spacing: 0) {
          ForEach(times.indices, id: \.self) { index in
            TimeRow(timeText: times[index], pointColor: .orange, pills: pills[index])
          }
        }
      }

      Divider()

      HStack(spacing: .smallSpacing) {
        SectionHeader(title: "주기", systemImage: "arrow.triangle.2.circlepath")

        WeekdayChips(weekdays: normalizedWeekdays(from: cycle))
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .padding(.bottom, .defaultSpacing)

      NavigationLink {
        AddSupplementView(type: .edit, context: context)
      } label: {
        HStack(spacing: .smallSpacing) {
          Image(systemName: "square.and.pencil")
          Text("내 일정 수정 하러 가기")
            .font(.notoSans(weight: .bold, size: 15))

          Spacer()

          Image(systemName: "chevron.right")
            .font(.notoSans(weight: .semiBold, size: 15))
        }
        .padding(.vertical, .defaultSpacing)
        .padding(.horizontal, .defaultSpacing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(
          colorScheme == .dark
          ? Color.orange.opacity(0.7)
          : Color.orange
        )
        .foregroundStyle(Color.white)
        .cornerRadius(.defaultRadius)
      }
      .buttonStyle(.plain)
    }
  }

  private func normalizedWeekdays(from cycle: String) -> [String] {
    let order = ["월","화","수","목","금","토","일"]

    if cycle.trimmingCharacters(in: .whitespacesAndNewlines) == "매일" {
      return order
    }

    if cycle.contains("매주") {
      return cycle
        .split(separator: "·")
        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    }

    let mapping: [String: String] = [
      "월요일": "월", "화요일": "화", "수요일": "수",
      "목요일": "목", "금요일": "금", "토요일": "토", "일요일": "일"
    ]

    let raw = cycle
      .split(separator: "·")
      .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
      .map { mapping[$0] ?? $0 }
      .filter { !$0.isEmpty }

    let unique = Array(NSOrderedSet(array: raw)) as? [String] ?? raw
    return unique.sorted { (a, b) -> Bool in
      (order.firstIndex(of: a) ?? .max) < (order.firstIndex(of: b) ?? .max)
    }
  }
}

#Preview("Mine") {
  NavigationStack {
    VStack(spacing: .defaultSpacing) {
      SchedulePanel(
        times: ["오전 8:00", "오후 8:00"],
        cycle: "월·수·금",
        pills: ["1정", "2정"]
      )
    }
  }
  .environment(\.locale, Locale(identifier: "ko_KR"))
}

#Preview("Mine-월요일만 있다면") {
  NavigationStack {
    VStack(spacing: .defaultSpacing) {
      SchedulePanel(
        times: ["오전 8:00", "오후 8:00"],
        cycle: "월요일",
        pills: ["2", "3"]
      )
    }
  }
  .environment(\.locale, Locale(identifier: "ko_KR"))
}
