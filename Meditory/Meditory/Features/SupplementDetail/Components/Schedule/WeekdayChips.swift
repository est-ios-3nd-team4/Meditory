//
//  WeekdayChips.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

struct WeekdayChips: View {
  let weekdays: [String]

  var body: some View {
    HStack(spacing: .smallSpacing) {
      Spacer(minLength: 0)
      ForEach(weekdays, id: \.self) { text in
        Text(text)
          .font(.notoSans(size: 13))
          .fontWeight(.semibold)
          .padding(.horizontal, .smallSpacing)
          .padding(.vertical, .smallSpacing / 2)
          .background(
            Capsule().fill(Color.secondary.opacity(0.12))
          )
          .foregroundStyle(.secondary)
          .accessibilityLabel("\(text) 주기")
      }
    }
  }
}
