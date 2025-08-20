//
//  TimeRow.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

struct TimeRow: View {
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

      if !period.isEmpty {
        Text(period)
          .font(.notoSans(size: 14))
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)
      }

      Spacer(minLength: .defaultSpacing)

      Text(hm.isEmpty ? timeText : hm)
        .font(.notoSans(size: 15))
        .fontWeight(.bold)
        .foregroundStyle(accent)
    }
    .padding(.vertical, .smallSpacing)
  }
}
