//
//  CircleCheck.swift
//  Meditory
//
//  Created by 윤혜주 on 8/5/25.
//

import SwiftUI

struct CircleCheck: View {
  var isCompleted: Bool
  var size: CGFloat = 20
  var defaultWidthWitGray: Bool = true
  var body: some View {
    ZStack {
      Circle()
        .fill(isCompleted ? Color.main : Color.white)
      
      if isCompleted {
        Image(systemName: "checkmark")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: size * 0.5, height: size * 0.5)
          .foregroundColor(.white)
          .fontWeight(.bold)
      } else {
        if defaultWidthWitGray {
          Circle()
            .strokeBorder(Color.gray.opacity(0.4))
        } else {
          Circle()
            .strokeBorder(Color.gray, lineWidth: size * 0.08)
        }
      }
    }
    .frame(width: size, height: size)
  }
}
