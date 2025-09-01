//
//  GuideCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//

import SwiftUI

/// **보조제(영양제/약) 정보 카드 뷰**
/// - 역할:
///   - 루틴(보조제)의 기본 정보(이름, 설명, 아이콘)를 헤더 카드 형태로 표시
///   - 복용법/주의사항/메모 등 추가 가이드를 리스트 형태로 표시
/// - 스타일:
///   - `UnifiedSectionCard` 기반 공통 카드 레이아웃 적용
///   - 가이드 종류에 따라 배경색과 포인트 색상이 달라짐
struct SupplementInfoCard: View {
  // MARK: - Mode
  /// 카드 표시 모드
  enum Mode: Equatable {
    /// 상단 헤더 카드 (제목, 부제목, 색상, 아이콘)
    case header(
      title: String,
      subtitle: String?,
      tint: Color,
      icon: String
    )
    /// 가이드 카드 (제목, 아이콘, 색상, 불릿 리스트)
    case guide(
      title: String,
      icon: String,
      tint: Color,
      bullets: [String]
    )
  }
  
  // MARK: - GuideType
  /// 가이드 타입(복용법/주의사항/메모)
  enum GuideType {
    case info, warn, memo
    
    /// 카드 제목
    var title: String {
      switch self {
      case .info: return "복용법"
      case .warn: return "복용 주의 사항"
      case .memo: return "메모"
      }
    }
    
    /// 아이콘 심볼
    var icon: String {
      switch self {
      case .info: return "pills.fill"
      case .warn: return "exclamationmark.triangle.fill"
      case .memo: return "doc.fill"
      }
    }
    
    /// 포인트 색상
    var tint: Color {
      switch self {
      case .info: return .main
      case .warn: return .orange
      case .memo: return .purple
      }
    }
  }
  
  // MARK: - Environment
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.horizontalSizeClass) private var hSize
  
  // MARK: - Layout
  private var isPadStyle: Bool { hSize == .regular }
  private var titleFontSize: CGFloat { .defaultFontSize }
  private var subtitleFontSize: CGFloat { .defaultFontSize - 4 }
  private var textFontSize: CGFloat { .defaultFontSize - 3 }
  
  // MARK: - Properties
  let mode: Mode
  
  // MARK: - Initializers
  /// 루틴(`Routine`)을 기반으로 헤더 카드를 생성합니다.
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
  
  /// 제목/부제목/카테고리 정보를 기반으로 헤더 카드를 생성합니다.
  init(title: String, subtitle: String?, category: String?, displayName: String) {
    let style = RoutineIconResolver.style(category: category, displayName: displayName)
    self.mode = .header(
      title: title,
      subtitle: subtitle,
      tint: style.color,
      icon: style.symbol
    )
  }
  
  /// 가이드 타입과 불릿 리스트를 기반으로 가이드 카드를 생성합니다.
  init(type: GuideType, guide: [String]) {
    self.mode = .guide(
      title: type.title,
      icon: type.icon,
      tint: type.tint,
      bullets: guide
    )
  }
  
  // MARK: - Body
  var body: some View {
    Group {
      // 복용법/주의사항은 강조 배경 적용
      if case .guide(let title, _, let tint, _) = mode,
         (title == GuideType.info.title || title == GuideType.warn.title) {
        UnifiedSectionCard(
          pointColor: mode.tint,
          backgroundColor: tint.opacity(colorScheme == .dark ? 0.2 : 0.1)
        ) {
          content
        }
      } else {
        UnifiedSectionCard() {
          content
        }
      }
    }
  }
  
  // MARK: - Content Builder
  @ViewBuilder
  private var content: some View {
    VStack(alignment: .leading, spacing: .smallSpacing) {
      // 헤더 영역 (아이콘 + 제목)
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
      
      // 내용
      switch mode {
      case .header:
        // 부제목 표시
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
        // 불릿 리스트 표시
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

// MARK: - Mode Extensions
extension SupplementInfoCard.Mode {
  /// 카드 제목
  var title: String {
    switch self {
    case let .header(title, _, _, _): return title
    case let .guide(title, _, _, _):  return title
    }
  }
  
  /// 카드 아이콘
  var icon: String {
    switch self {
    case let .header(_, _, _, icon):  return icon
    case let .guide(_, icon, _, _):   return icon
    }
  }
  
  /// 포인트 색상
  var tint: Color {
    switch self {
    case let .header(_, _, tint, _):  return tint
    case let .guide(_, _, tint, _):   return tint
    }
  }
  
  /// 부제목 (헤더 모드 전용)
  var subtitle: String? {
    if case let .header(_, subtitle, _, _) = self { return subtitle }
    return nil
  }
  
  /// 불릿 리스트 (가이드 모드 전용)
  var bullets: [String] {
    if case let .guide(_, _, _, bullets) = self { return bullets }
    return []
  }
}
