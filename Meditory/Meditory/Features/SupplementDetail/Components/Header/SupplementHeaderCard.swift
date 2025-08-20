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
  var accentColor: Color = .orange
  var systemIcon: String = "capsule.portrait.fill"

  /// Routine으로부터 아이콘/색상 자동 설정
  init(routine: Routine) {
    let style = RoutineIconResolver.style(
      category: routine.category,
      displayName: routine.displayName
    )
    self.title       = routine.displayName
    self.subtitle    = routine.desc ?? ""
    self.accentColor = style.color
    self.systemIcon  = style.symbol
  }

  /// category(String) & displayName 수동 전달 버전 (subtitle은 직접 지정)
  init(title: String, subtitle: String, category: String?, displayName: String) {
    let style = RoutineIconResolver.style(category: category, displayName: displayName)
    self.title = title
    self.subtitle = subtitle
    self.accentColor = style.color
    self.systemIcon  = style.symbol
  }

  private var hasSubtitle: Bool {
    !subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  var body: some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      HStack(spacing: .smallSpacing) {
        Image(systemName: systemIcon)
          .imageScale(.medium)
          .padding(.smallSpacing)
          .background(Circle().fill(accentColor.opacity(0.15)))
          .foregroundStyle(accentColor)
          .accessibilityHidden(true) // 장식 아이콘

        Text(title)
          .font(.notoSans(size: 18))
          .fontWeight(.bold)
          .lineLimit(1)
          .minimumScaleFactor(0.85)

        Spacer(minLength: 0)
      }

      if hasSubtitle {
        Text(subtitle)
          .font(.notoSans(weight: .regular, size: 14))
          .foregroundStyle(.secondary)
          .lineLimit(2)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.defaultSpacing)
    .background(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .fill(colorScheme == .dark
              ? Color.white.opacity(0.08)
              : Color(.secondarySystemGroupedBackground))
    )
    .modifier(UnifiedShadow())
    .overlay(
      RoundedRectangle(cornerRadius: .defaultRadius, style: .continuous)
        .stroke(accentColor.opacity(0.3), lineWidth: 1)
    )
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
      pillsPerDose: 1
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
      pillsPerDose: 2
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
      pillsPerDose: 1
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
      pillsPerDose: 1
    )
  )
  .padding()
  .background(Color.customBackground)
}
