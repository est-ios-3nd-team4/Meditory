//
//  DailyNutritionView.swift
//  Meditory
//
//  Created by 이치훈 on 8/4/25.
//

import SwiftUI

enum MacroNutrient {
  case carbohydrate
  case protein
  case fat
}

struct DailyNutritionView: View {
  
  var body: some View {
    CalendarBackgroundView {
      VStack {
        ZStack {
          Rectangle()
            .fill(Color.customContainer)
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .modifier(UnifiedShadow())
            .padding(20)
          
          HStack {
            Text("오늘 하루 식단")
              .foregroundStyle(.black)
            
            VStack {
              HStack {
                Circle()
                  .fill(.customCarbohydrate)
                  .frame(width: 10, height: 10)
                
                Text("탄수화물")
                  .foregroundStyle(.black)
              }
            }
          }
        }
      }
    }
  }
  
}

#Preview {
  DailyNutritionView()
}
