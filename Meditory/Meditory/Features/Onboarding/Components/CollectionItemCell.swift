//
//  CollectionItemCell.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct CollectionItemCell: View {
  var model:QuestionModel
  var isSelected: Bool = false
  
  var body: some View {
    VStack {
      ZStack {
        RoundedRectangle(cornerRadius: .defaultSpacing)
          .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
          .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
          .adaptiveImage(100)
          .foregroundStyle(.sub.opacity(0.14))
          .zIndex(0)
        Image(model.image)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .adaptiveImage(100)
            .saturation(isSelected ? 1 : 0)
            .cornerRadius(.defaultRadius)
      }
      .modifier(UnifiedShadow())
      Text(model.title)
        .font(.notoSans(weight: .medium, size: 14))
        .foregroundStyle(isSelected ? Color.label : .textGray)
    }
    .frame(width: 140,height: 140)
  }
}

#Preview {
//  CollectionItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: true)
//  CollectionItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: false)
}
