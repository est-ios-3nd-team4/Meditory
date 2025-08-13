//
//  MealSummaryCell.swift
//  Meditory
//
//  Created by 이치훈 on 8/7/25.
//

import SwiftUI

struct MealSummaryView: View {
  
  let macros = [
    MacroModel(macroType: .carbohydrate,
               gram: 180),
    MacroModel(macroType: .protein,
               gram: 30),
    MacroModel(macroType: .fat,
               gram: 10)
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
                
                HStack {
                  Text(macro.label)
                    .font(.custom("NotoSansKR-Bold", size: 17))
                  
                  Text("\(Int(macro.gram))g")
                    .font(.custom("NotoSansCJKkr-Medium", size: 18))
                }
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
