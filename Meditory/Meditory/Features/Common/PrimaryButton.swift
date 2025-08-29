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
      action()
    } label: {
      RoundedRectangle(cornerRadius: 10)
        .fill(isSub ? Color.init(red: 229, green: 242, blue: 255) : (isEnabled ? .main : .gray.opacity(0.4)))
        .frame(height: 50)
        .overlay {
          Text(title)
            .font(.notoSans(weight: .semiBold, size: isPad ? 28 : 18))
            .foregroundStyle(isSub ? .main : .white)
        }
    }
  }
}
