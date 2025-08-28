//
//  ImageWithTitle.swift
//  Meditory
//
//  Created by hyunsic on 8/20/25.
//

import SwiftUI

struct ImageWithTitle: View {

  var gender: Gender
  var isSelected: Bool
  var onAction: (() -> Void)?
  var body: some View {

    VStack(spacing: .defaultSpacing + 8) {
      Image(gender.image)
        .resizable()
        .aspectRatio(contentMode: .fit)
//        .frame(width: 110, height: 110)
        .adaptiveImage(110,small: -30)
        .saturation(isSelected ? 1 : 0)
        .overlay(
          RoundedRectangle(cornerRadius: .defaultRadius)
            .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3))
            .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
        )
        .onTapGesture {
          onAction?()
        }
      Text(gender.title)
        .font(.notoSans(weight: .medium, size: 18))
        .adaptiveFont(18,small: -4,weight: .medium)
        .foregroundStyle(isSelected ? Color.label : .textGray)
        .padding(.bottom,4)
    }
  }
}

