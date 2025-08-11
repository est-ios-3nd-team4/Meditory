//
//  ItemCell.swift
//  Meditory
//
//  Created by hyunsic on 8/8/25.
//

import SwiftUI

struct ItemCell: View {
  var body: some View {
    VStack {
      ZStack {
//        RoundedRectangle(cornerRadius: 14)
//          .frame(width: 100, height: 100)
//          .foregroundStyle(.sub.opacity(0.3))
//          .zIndex(0)
//          .shadow(color:.gray,radius: .defaultRadius,y:15)
        Image("lung")
          .renderingMode(.original)
          .resizable()
          .scaledToFit()
          .frame(width: 110,height: 110)
          .cornerRadius(20)
        RoundedRectangle(cornerRadius: 6)
          .frame(width: 70, height: 30)
          .foregroundStyle(.sub)
          .overlay {
            Text("20대 추천")
              .font(.notoSans(weight: .regular, size: 10))
              .foregroundStyle(.white)
          }.zIndex(1)
          .offset(y:-55)
      }
      Text("피부 건강")
        .font(.notoSans(weight: .semiBold, size: 18))
    }
    .frame(width: 160,height: 160)
  }
}

#Preview {
  ItemCell()
}
