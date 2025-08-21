//
//  IntakeAddButton.swift
//  Meditory
//
//  Created by 홍승아 on 8/21/25.
//

import SwiftUI

struct IntakeAddButton: View {
  static let size = CGSize(width: 72, height: 72)
  
  var body: some View {
    Circle()
      .frame(width: Self.size.width, height: Self.size.height)
      .foregroundStyle(
        LinearGradient(
          stops: [
            .init(color: .init(red: 89, green: 171, blue: 255), location: 0.0),
            .init(color: .init(red: 51, green: 151, blue: 255), location: 0.13),
            .init(color: .main, location: 1.0),
          ],
          startPoint: .leading,
          endPoint: .trailing
        )
      )
      .overlay {
        Image(systemName: TabItem.add.iconImage)
          .font(.system(size: 35, weight: .semibold))
          .foregroundStyle(.white)
      }
  }
}
