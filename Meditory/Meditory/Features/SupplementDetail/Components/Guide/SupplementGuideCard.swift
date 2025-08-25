//
//  GuideCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct SupplementInfoCard: View {
  enum Mode: Equatable {
    case header(
      title: String,
      subtitle: String?,
      tint: Color,
      icon: String
    )
    case guide(
      title: String,
      icon: String,
      tint: Color,
      bullets: [String]
    )
  }

  enum GuideType {
    case info, warn, memo

    var title: String {
      switch self {
      case .info: return "복용법"
      case .warn: return "복용 주의 사항"
      case .memo: return "메모"
      }
    }

    var icon: String {
      switch self {
      case .info: return "pills.fill"
      case .warn: return "exclamationmark.triangle.fill"
      case .memo: return "doc.fill"
      }
    }

    var tint: Color {
      switch self {
      case .info: return .main
      case .warn: return .orange
      case .memo: return .purple
      }
    }
  }

  @Environment(\.horizontalSizeClass) private var hSize
  private var isPadStyle: Bool { hSize == .regular }
  private var titleFontSize: CGFloat { isPadStyle ? 20 : 18 }
  private var subtitleFontSize: CGFloat { isPadStyle ? 16 : 14 }
  private var textFontSize: CGFloat { isPadStyle ? 17 : 15 }

  let mode: Mode

  init(routine: Routine) {
    let style = RoutineIconResolver.style(
      category: routine.category,
      displayName: routine.displayName
    )
    self.mode = .header(
      title: routine.displayName,
      subtitle: routine.desc,
      tint: style.color,
      icon: style.symbol
    )
  }

  init(title: String, subtitle: String?, category: String?, displayName: String) {
    let style = RoutineIconResolver.style(category: category, displayName: displayName)
    self.mode = .header(
      title: title,
      subtitle: subtitle,
      tint: style.color,
      icon: style.symbol
    )
  }

  init(type: GuideType, guide: [String]) {
    self.mode = .guide(
      title: type.title,
      icon: type.icon,
      tint: type.tint,
      bullets: guide
    )
  }

  var body: some View {
    UnifiedSectionCard(pointColor: mode.tint) {
      VStack(alignment: .leading, spacing: .smallSpacing) {
        HStack(spacing: .smallSpacing) {
          Image(systemName: mode.icon)
            .imageScale(.medium)
            .padding(.smallSpacing)
            .background(Circle().fill(mode.tint.opacity(0.15)))
            .foregroundStyle(mode.tint)
            .accessibilityHidden(true)

          Text(mode.title)
            .font(.notoSans(size: titleFontSize))
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.85)

          Spacer()
        }

        switch mode {
        case .header:
          if let subtitle = mode.subtitle?.trimmingCharacters(in: .whitespacesAndNewlines),
             !subtitle.isEmpty {
            HStack(alignment: .top, spacing: .smallSpacing) {
              Circle()
                .frame(width: 5, height: 5)
                .foregroundStyle(mode.tint.opacity(0.8))
                .padding(.top, .smallSpacing)

              Text(subtitle)
                .font(.notoSans(weight: .regular, size: subtitleFontSize))
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            }
          }

        case .guide:
          VStack(alignment: .leading, spacing: .smallSpacing) {
            ForEach(mode.bullets, id: \.self) { text in
              HStack(alignment: .top, spacing: .smallSpacing) {
                Circle()
                  .frame(width: 5, height: 5)
                  .foregroundStyle(mode.tint.opacity(0.8))
                  .padding(.top, .smallSpacing)

                Text(text)
                  .font(.notoSans(weight: .regular, size: textFontSize))
                  .foregroundStyle(.primary)
                  .fixedSize(horizontal: false, vertical: true)
              }
            }
          }
        }
      }
    }
  }
}
extension SupplementInfoCard.Mode {
  var title: String {
    switch self {
    case let .header(title, _, _, _): return title
    case let .guide(title, _, _, _):  return title
    }
  }

  var icon: String {
    switch self {
    case let .header(_, _, _, icon):  return icon
    case let .guide(_, icon, _, _):   return icon
    }
  }

  var tint: Color {
    switch self {
    case let .header(_, _, tint, _):  return tint
    case let .guide(_, _, tint, _):   return tint
    }
  }

  var subtitle: String? {
    if case let .header(_, subtitle, _, _) = self { return subtitle }
    return nil
  }

  var bullets: [String] {
    if case let .guide(_, _, _, bullets) = self { return bullets }
    return []
  }
}


#Preview("Header - Vitamin C") {
  SupplementInfoCard(
    routine: Routine(
      type: 1,
      displayName: "비타민C",
      desc: "면역력 강화 · 피로 회복",
      category: "비타민",
      cycleType: 1,
      cycleValue: "0",
      startDate: Date()
    )
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Header - Omega-3 Dark") {
  SupplementInfoCard(
    routine: Routine(
      type: 1,
      displayName: "오메가-3",
      desc: "혈관 건강 · 혈행 개선 · 콜레스테롤 개선",
      category: "오메가",
      cycleType: 1,
      cycleValue: "1,3,5",
      startDate: Date()
    )
  )
  .padding()
  .background(Color.customBackground)
  .environment(\.colorScheme, .dark)
}

#Preview("Header - Lutein / no desc") {
  SupplementInfoCard(
    routine: Routine(
      type: 1,
      displayName: "루테인",
      desc: nil,
      category: "루테인",
      cycleType: 1,
      cycleValue: "2,4,6",
      startDate: Date()
    )
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Guide - Info") {
  SupplementInfoCard(
    type: .info,
    guide: [
      "식사와 함께 충분한 물과 복용하세요.",
      "위장 부담을 줄이려면 식후 복용이 좋아요."
    ]
  )
  .padding()
  .background(Color.customBackground)
}

#Preview("Guide - Warn — Dark") {
  SupplementInfoCard(
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

#Preview("Guide - Memo") {
  SupplementInfoCard(
    type: .memo,
    guide: [
      "아침밥 먹고 바로 복용하기",
      "점심은 꼭 물 많이 마시고 먹기"
    ]
  )
  .padding()
  .background(Color.customBackground)
}
