//
//  PrimaryButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

struct PrimaryButton: View {
  let isPad = UIDevice.isPad
  let title: String
  var isEnabled: Bool = true
  var isSub: Bool = false
  let action: () -> Void
  
  var body: some View {
    Button {
      if isEnabled {
        action()
      }
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isSub
              ? (isEnabled ? .main.opacity(0.3) : .main)
              : (isEnabled ? .main : .gray.opacity(0.4)))
        .frame(height: isPad ? 60 : 50)
        .overlay {
          Text(title)
            .font(.notoSans(weight: .semiBold, size: isPad ? 28 : 18))
            .foregroundStyle(isSub
                             ? (isEnabled ? .main : .main.opacity(0.3)) // sub style
                             : (isEnabled ? .white : .white.opacity(0.6))) // main style
        }
    }
  }
}

#Preview {
  PrimaryButton(title: "Hello World", isEnabled: false, isSub: true, action: {})
}
