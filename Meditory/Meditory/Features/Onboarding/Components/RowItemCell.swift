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
  var subTitleSize:Double = 14
  
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .stroke(isSelected ? Color.main : Color.gray.opacity(0.3), lineWidth: 1)
        .fill(isSelected ? Color.sub.opacity(0.14) : Color.clear)
        .frame(height: 100)
      HStack(alignment: .center) {
        Image(model.image)
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 60, height: 60)
          .saturation(isSelected ? 1 : 0 )
          .alignmentGuide(.top) { d in d[.top] - 4 }
        VStack(alignment: .leading, spacing: 2) {
          Text(model.title)
            .font(.notoSans(weight: .semiBold, size: 14))
          Text(model.subtitle)
            .font(.notoSans(weight: .regular, size: subTitleSize))
        }
        .foregroundStyle(.textGray)
        Spacer()
        CircleCheck(isCompleted: isSelected, size: 25)
          .padding(.trailing, 20)
      }
      .padding(10)
    }
  }
}

#Preview {
//  RowItemCell(model: .init(title: "땅콩", subtitle:"땅콩호두,아몬드,피스타치오,헤이즐넛",toggleImage: .name(base: "nuts_seeds")), isSelected: false)
//  RowItemCell(model: .init(title: "땅콩", subtitle:"땅콩호두,아몬드,피스타치오,헤이즐넛",toggleImage: .name(base: "nuts_seeds")), isSelected: true)
}

#Preview("dark") {
//  RowItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: true)
//    .preferredColorScheme(.dark)
//  RowItemCell(model: .init(title: "간", image: "icon_clear_lung"), isSelected: false)
//    .preferredColorScheme(.dark)
}
