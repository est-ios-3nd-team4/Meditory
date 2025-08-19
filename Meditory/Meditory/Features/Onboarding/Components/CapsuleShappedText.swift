//
//  CapsuleShappedText.swift
//  Meditory
//
//  Created by hyunsic on 8/19/25.
//

import SwiftUI

struct CapsuleShappedText: View {
  let title: String
  var isSelected: Bool

  var body: some View {
    Text("\(title)")
      .font(.notoSans(weight: .medium, size: 15))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(isSelected ? Color.main.opacity(0.7) : Color.gray.opacity(0.5), lineWidth: 1)
      }
  }
}
