//
//  GuideCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SupplementGuideCard: View {
  enum GuideType { case info, warn }

  let title: String
  let icon: String
  let type: GuideType
  let guide: [String]

  private var tint: Color {
    type == .info ? .main : .orange
  }

  private var backgroundColor: Color {
    type == .info ? Color.main.opacity(0.08) : Color.yellow.opacity(0.12)
  }
  
  var body: some View {
    UnifiedSectionCard(accentColor: tint) {
      HStack(spacing: .smallSpacing) {
        Image(systemName: icon)
          .imageScale(.medium)
          .padding(.smallSpacing)
          .background(Circle().fill(tint.opacity(0.15)))
          .foregroundStyle(tint)
          .accessibilityHidden(true)

        Text(title)
          .font(.notoSans(size: 18))
          .fontWeight(.bold)

        Spacer()
      }

      VStack(alignment: .leading, spacing: .smallSpacing) {
        ForEach(guide, id: \.self) { text in
          HStack(alignment: .top, spacing: .smallSpacing) {
            Circle()
              .frame(width: 5, height: 5)
              .foregroundStyle(tint.opacity(0.8))
              .padding(.top, .smallSpacing)

            Text(text)
              .font(.notoSans(weight: .regular, size: 15))
              .foregroundStyle(.primary)
          }
        }
      }
    }
  }
}

#Preview("Info") {
  SupplementGuideCard(
    title: "복용법",
    icon: "pills.fill",
    type: .info,
    guide: [
      "식사와 함께 충분한 물과 복용하세요.",
      "위장 부담을 줄이려면 식후 복용이 좋아요."
    ]
  )
  .padding()
  .background(Color.customBackground)
}
#Preview("Info - Dark Mode") {
  SupplementGuideCard(
    title: "복용법",
    icon: "pills.fill",
    type: .info,
    guide: [
      "식사와 함께 충분한 물과 복용하세요.",
      "위장 부담을 줄이려면 식후 복용이 좋아요."
    ]
  )
  .padding()
  .background(Color.customBackground)
  .environment(\.colorScheme, .dark)
}

#Preview("Warn") {
  SupplementGuideCard(
    title: "복용 주의 사항",
    icon: "exclamationmark.triangle.fill",
    type: .warn,
    guide: [
      "혈전 위험이 있는 경우 전문의 상담 후 복용하세요.",
      "과다 섭취 시 소화불량·출혈 위험이 있을 수 있습니다."
    ]
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Warn — Dark Mode") {
  SupplementGuideCard(
    title: "복용 주의 사항",
    icon: "exclamationmark.triangle.fill",
    type: .warn,
    guide: [
      "혈전 위험이 있는 경우 전문의 상담 후 복용하세요.",
      "과다 섭취 시 소화불량·출혈 위험이 있을 수 있습니다."
    ]
  )
  .padding()
  .background(Color.customBackground)
  .environment(\.colorScheme, .dark)
}
