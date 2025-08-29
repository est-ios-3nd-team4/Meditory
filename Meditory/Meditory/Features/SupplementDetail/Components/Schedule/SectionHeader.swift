//
//  SectionHeader.swift
//  Meditory
//
//  Created by 윤혜주 on 8/20/25.
//

import SwiftUI

struct SectionHeader: View {
  let title: String
  let systemImage: String
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    HStack(spacing: .smallSpacing / 2) {
      ZStack {
        Circle()
          .fill(Color.main)
          .frame(width: 20, height: 20)

        Image(systemName: systemImage)
          .resizable()
          .scaledToFit()
          .frame(width: 10, height: 10)
          .foregroundStyle(.white)
      }

      Text(title)
        .font(.notoSans(size: .defaultFontSize - 5))
        .foregroundStyle(colorScheme == .dark ? .white : .main)
    }
    .padding(.horizontal, .smallSpacing)
    .padding(.vertical, .smallSpacing / 2)
    .background(Color.blue.opacity(0.1), in: Capsule())
  }
}
