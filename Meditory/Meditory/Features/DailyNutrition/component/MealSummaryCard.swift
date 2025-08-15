//
//  MealSummaryCell.swift
//  Meditory
//
//  Created by 이치훈 on 8/7/25.
//

import SwiftUI

struct MealSummaryCard: View {
  
  let meal: MealInfo
  // TODO: Food로 변경
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
            .font(.notoSans(weight: .bold, size: 18))
          
          HStack(spacing: 40) {
            ForEach(meal.macroItems) { item in
              HStack {
                Circle()
                  .fill(item.color)
                  .frame(width: 15, height: 15)
                
                HStack {
                  Text(item.label)
                    .font(.notoSans(weight: .bold, size: 17))
                  
                  Text("\(Int(item.gram))g")
                    .font(.notoSans(weight: .medium, size: 18))
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
  MealSummaryCard(meal: MealInfo(name: "아침",
                                 foods: [FoodInfo(name: "짜장면",
                                                  weight: 120,
                                                  macros: .init(carbohydrate: 30,
                                                                protein: 10,
                                                                fat: 5)),
                                         FoodInfo(name: "스파게티",
                                                  weight: 150,
                                                  macros: .init(carbohydrate: 40,
                                                                protein: 50,
                                                                fat: 10))
                                 ]))
}
