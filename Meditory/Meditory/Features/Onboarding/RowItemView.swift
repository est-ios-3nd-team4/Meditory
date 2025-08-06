//
//  RowItemView.swift
//  Meditory
//
//  Created by hyunsic on 8/4/25.
//

import SwiftUI

struct RowItemView: View {
  var isSelected:Bool
  var context:String
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 8)
        .stroke(isSelected ? Color.main : Color.gray.opacity(0.4),lineWidth: 1)
        .frame(height: 60)
        .foregroundStyle(.clear)
      HStack {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle" )
          .renderingMode(.template)
        
          .foregroundStyle(Color.main)
        Text(context)
          .font(.notoSans(weight: .bold, size: 16))
        Spacer()
      }
      .padding(10)
    }
    .padding(.horizontal)
  }
}

#Preview {
  RowItemView(isSelected: true, context: "Hello")
  RowItemView(isSelected: false, context: "Hello")
}
