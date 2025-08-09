//
//  HeaderCard.swift
//  Meditory
//
//  Created by 윤혜주 on 8/9/25.
//
import SwiftUI

struct HeaderCard: View {
  @Environment(\.colorScheme) private var colorScheme

  let title: String
  let subtitle: String
  let emoji: String

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        Text(title)
          .font(.notoSans(size: 18))
          .fontWeight(.bold)
        Text(emoji)
          .font(.notoSans(size: 18))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.bottom, .smallSpacing)
      Text(subtitle)
        .font(.notoSans(weight: .regular, size: 14))
        .foregroundStyle(.secondary)
        .lineLimit(2)
    }
    .frame(maxWidth: .infinity)
    .padding(.defaultSpacing)
    .background(colorScheme == .dark ? Color.white.opacity(0.3) : Color.white)
    .cornerRadius(20)
    .modifier(UnifiedShadow())
  }
}
#Preview("Light Mode") {
    HeaderCard(
        title: "오메가",
        subtitle: "혈관 건강 · 시력 유지 · 콜레스테롤 수치 개선에 도움",
        emoji: "🩸"
    )
    .padding()
    .background(Color.customBackground)
}

#Preview("Dark Mode") {
    HeaderCard(
        title: "오메가",
        subtitle: "혈관 건강 · 시력 유지 · 콜레스테롤 수치 개선에 도움",
        emoji: "🩸"
    )
    .padding()
    .background(Color.customBackground)
    .environment(\.colorScheme, .dark)
}
