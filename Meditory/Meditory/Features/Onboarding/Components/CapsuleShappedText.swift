//
//  CapsuleShappedText.swift
//  Meditory
//
//  Created by hyunsic on 8/19/25.
//

import SwiftUI

struct CapsuleShappedText: View {
  let isPad = UIDevice.isPad
  let title: String
  var isSelected: Bool

  var body: some View {
    Text("\(title)")
      .adaptiveFont(.defaultFontSize - 3,weight: .medium)
      .foregroundStyle(isSelected ? Color.white: .sub)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .fill(isSelected ? .main : .clear)
      }
      .overlay {
        RoundedRectangle(cornerRadius: .defaultRadius)
          .stroke(isSelected ? Color.main : Color.gray.opacity(0.3),lineWidth: 1)
      }
      .animation(.easeInOut(duration: 0.3), value: isSelected)
  }
}
