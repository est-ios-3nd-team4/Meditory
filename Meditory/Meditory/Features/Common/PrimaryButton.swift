//
//  PrimaryButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/22/25.
//

import SwiftUI

struct PrimaryButton: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void
  
  var body: some View {
    Button {
      action()
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isEnabled ? Color.main : Color.gray.opacity(0.4))
        .frame(height: 50)
        .overlay {
          Text(title)
            .font(.notoSans(weight: .semiBold, size: 18))
            .foregroundStyle(.white)
        }
    }
  }
}
