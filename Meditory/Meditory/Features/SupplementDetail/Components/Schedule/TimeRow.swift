//
//  TimeRow.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

struct TimeRow: View {
  let timeText: String
  let pointColor: Color
  let pills: String

  var body: some View {
    HStack(spacing: .smallSpacing) {
      IconBadge(
        systemName: "clock.fill",
        backgroundColor: pointColor.opacity(0.12),
        foregroundColor: pointColor
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

      Text(hm.isEmpty ? timeText : hm)
        .font(.notoSans(size: 15))
        .fontWeight(.bold)
        .foregroundStyle(pointColor)

      Spacer(minLength: .defaultSpacing)

      HStack(spacing: .smallSpacing) {
        Image(systemName: "pills.fill")
          .imageScale(.small)

        Text(pills)
          .font(.notoSans(size: 13))
      }
      .padding(.horizontal, .smallSpacing)
      .padding(.vertical, .smallSpacing)
      .background(
        Capsule()
          .fill(Color.secondary.opacity(0.12))
      )
    }
    .padding(.vertical, .smallSpacing)
  }
}
