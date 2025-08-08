//
//  MealSummaryCell.swift
//  Meditory
//
//  Created by 이치훈 on 8/7/25.
//

import SwiftUI

struct MealSummaryView: View {
  
  let macros = [
    MacroModel(id: 0,
               color: .customCarbohydrate,
               label: "탄",
               gram: 150),
    MacroModel(id: 1,
               color: .customProtein,
               label: "단",
               gram: 120),
    MacroModel(id: 2,
               color: .customFat,
               label: "지",
               gram: 80)
  ]
  
  var body: some View {
    ZStack {
      Rectangle()
        .fill(.customContainer)
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .modifier(UnifiedShadow())
      
      HStack {
        VStack(alignment: .leading, spacing: 16) {
          Text("아침")
            .font(.custom("NotoSansKR-Bold", size: 18))
          
          HStack(spacing: 40) {
            ForEach(macros) { macro in
              HStack {
                Circle()
                  .fill(macro.color)
                  .frame(width: 15, height: 15)
                
                Text(macro.label + " \(macro.gram)g")
              }
            }
          }
          
        }
        
        Spacer()
      }
      .padding(.leading, 16)
    }
  }
}

#Preview {
    MealSummaryView()
}
