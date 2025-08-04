//
//  RowItemView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct RowItemView: View {
  @State var isSelected:Bool
  @State var context:String
  var body: some View {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .stroke(isSelected ? Color.accent : Color.gray,lineWidth: 1)
          .frame(height: 60)
          .foregroundStyle(.clear)
        HStack {
          Image(systemName: isSelected ? "circle.fill" : "circle" )
            .renderingMode(.template)
            .foregroundStyle(Color.accent)
          Text(context)
            .font(.custom("NotoSansKR-Bold", size: 16))
          Spacer()
        }
        .padding(10)
      }
      .padding(.horizontal,)
    }
}

#Preview {
  RowItemView(isSelected: false,context: "당뇨")
  RowItemView(isSelected: true,context: "간질환")
}
