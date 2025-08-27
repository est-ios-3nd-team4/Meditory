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
  var isSub: Bool = false
  let action: () -> Void
  
  var body: some View {
    Button {
      action()
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isEnabled ? Color.main : Color.gray.opacity(0.4))
        .fill(isSub ? Color.init(red: 229, green: 242, blue: 255) : Color.main)
        .frame(height: 50)
        .overlay {
          Text(title)
            .font(.notoSans(weight: .semiBold, size: 18))
            .foregroundStyle(isSub ? .main : .white)
        }
    }
  }
}
