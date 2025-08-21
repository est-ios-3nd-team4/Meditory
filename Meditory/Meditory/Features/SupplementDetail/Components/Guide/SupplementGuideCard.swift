//
//  GuideCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SupplementGuideCard: View {
  enum GuideType {
    case info, warn, memo

    var title: String {
      switch self {
      case .info:
        return "복용법"
      case .warn:
        return "복용 주의 사항"
      case .memo:
        return "메모"
      }
    }

    var icon: String {
      switch self {
      case .info:
        return "pills.fill"
      case .warn:
        return "exclamationmark.triangle.fill"
      case .memo:
        return "doc.fill"
      }
    }

    var tint: Color {
      switch self {
      case .info:
        return .main
      case .warn:
        return .orange
      case .memo:
        return .purple
      }
    }
  }

  let type: GuideType
  let guide: [String]
  
  var body: some View {
    UnifiedSectionCard(accentColor: type.tint) {
      HStack(spacing: .smallSpacing) {
        Image(systemName: type.icon)
          .imageScale(.medium)
          .padding(.smallSpacing)
          .background(Circle().fill(type.tint.opacity(0.15)))
          .foregroundStyle(type.tint)
          .accessibilityHidden(true)

        Text(type.title)
          .font(.notoSans(size: 18))
          .fontWeight(.bold)

        Spacer()
      }

      VStack(alignment: .leading, spacing: .smallSpacing) {
        ForEach(guide, id: \.self) { text in
          HStack(alignment: .top, spacing: .smallSpacing) {
            Circle()
              .frame(width: 5, height: 5)
              .foregroundStyle(type.tint.opacity(0.8))
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

#Preview("Memo") {
  SupplementGuideCard(
    type: .memo,
    guide: [
      "아침밥 먹고 바로 복용하기",
      "점심은 꼭 물 많이 마시고 먹기"
    ]
  )
  .padding()
  .background(Color.customBackground)
}
