//
//  RowItemView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct RowItemCell: View {
  var model: QuestionModel
  var isSelected: Bool

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.4), lineWidth: 1)
        .fill(isSelected ? Color.sub.opacity(0.18) : Color.clear)
        .frame(height: 100)
      HStack {
        HStack(alignment: .top) {
          if let imageName = model.toggleImage?.selectedImage(isSelect: isSelected) {
            Image(imageName)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 60, height: 60)
              .alignmentGuide(.top) { d in d[.top] - 4 }
          }
          VStack(alignment: .leading, spacing: 6) {
            Text(model.title)
              .font(.notoSans(weight: .semiBold, size: 16))
            Text(model.subTitle)
              .font(.notoSans(weight: .regular, size: 10))
              .foregroundStyle(.textGray)
          }
        }
        Spacer()
        CircleCheck(isCompleted: isSelected, size: 25)
          .padding(.trailing, 20)
      }
      .padding(10)
    }
  }
}

#Preview {
  RowItemCell(model: .init(title: "간", toggleImage: .name(base: "icon_lung")), isSelected: false)
  RowItemCell(model: .init(title: "간", toggleImage: .name(base: "icon_lung")), isSelected: true)
}

#Preview("dark") {
  RowItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: true)
    .preferredColorScheme(.dark)
  RowItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: false)
    .preferredColorScheme(.dark)
}
