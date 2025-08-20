//
//  HeaderCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import SwiftUI

struct SupplementHeaderCard: View {
  @Environment(\.colorScheme) private var colorScheme

  let title: String
  let subtitle: String
  var pointColor: Color = .orange
  var systemIcon: String = "capsule.portrait.fill"

  init(routine: Routine) {
    let style = RoutineIconResolver.style(
      category: routine.category,
      displayName: routine.displayName
    )
    self.title = routine.displayName
    self.subtitle = routine.desc ?? ""
    self.pointColor = style.color
    self.systemIcon = style.symbol
  }

  init(title: String, subtitle: String, category: String?, displayName: String) {
    let style = RoutineIconResolver.style(category: category, displayName: displayName)
    self.title = title
    self.subtitle = subtitle
    self.pointColor = style.color
    self.systemIcon = style.symbol
  }

  private var hasSubtitle: Bool {
    !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    UnifiedSectionCard(accentColor: pointColor) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack(spacing: .smallSpacing) {
          Image(systemName: systemIcon)
            .imageScale(.medium)
            .padding(.smallSpacing)
            .background(Circle().fill(pointColor.opacity(0.15)))
            .foregroundStyle(pointColor)
            .accessibilityHidden(true)

          Text(title)
            .font(.notoSans(size: 18))
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
        }

        if hasSubtitle {
          HStack(alignment: .top, spacing: .smallSpacing) {
            Circle()
              .frame(width: 5, height: 5)
              .foregroundStyle(pointColor.opacity(0.8))
              .padding(.top, .smallSpacing)

            Text(subtitle)
              .font(.notoSans(weight: .regular, size: 14))
              .foregroundStyle(.secondary)
              .lineLimit(2)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
      }
    }
  }
}

#Preview("Vitamin C") {
  SupplementHeaderCard(
    routine: Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화 · 피로 회복",
      category: "비타민",
      cycleType: 1,
      cycleValue: "0",
      startDate: Date(),
    )
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Omega-3 Dark") {
  SupplementHeaderCard(
    routine: Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈관 건강 · 혈행 개선 · 콜레스테롤 개선",
      category: "오메가",
      cycleType: 1,
      cycleValue: "1,3,5",
      startDate: Date(),
    )
  )
  .padding()
  .background(Color.customBackground)
  .environment(\.colorScheme, .dark)
}

#Preview("Lutein / no desc") {
  SupplementHeaderCard(
    routine: Routine(
      type: 1,
      displayName: "루테인",
      desc: nil, // desc 없음 → 서브타이틀 감춤
      category: "루테인",
      cycleType: 1,
      cycleValue: "2,4,6",
      startDate: Date(),
    )
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Probiotics") {
  SupplementHeaderCard(
    routine: Routine(
      type: 1,
      displayName: "유산균",
      desc: "장 건강 · 소화 개선",
      category: "프로바이오틱스",
      cycleType: 1,
      cycleValue: "매일",
      startDate: Date(),
    )
  )
  .padding()
  .background(Color.customBackground)
}
